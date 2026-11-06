#!/usr/bin/env python3
"""Mirror each organization repository's source into `<repo name>/...`.

The index records that a repository *exists*. This records what is *in* it.

The layout is the repository's own name at this repository's root:

    vorta-core/
        core/                  <- vortaforge/core, mirrored verbatim
        docs/                  <- vortaforge/docs
        .github/               <- the .github repository
        ...

Two consequences to understand before reading any diff:

* **A mirrored tree is a snapshot, not a working copy.** It has no `.git` of its
  own and nothing in it is editable. A file under `core/` is whatever
  `vortaforge/core` had on its default branch the last time the sync ran.
  `.mirror.json` at the top of each tree records the commit and the time.
* **`vorta-core` mirrors itself.** The repository listing includes this one, so
  `vorta-core/` holds a copy of this repository as of the *previous* mirrored
  commit. The copy is taken from GitHub, not from the working directory being
  built, so it never recurses: `vorta-core/vorta-core/` is absent because the
  clone predates the directory it would be written into.

Nested workflow files are inert. `vortaforge/.github` contains
`.github/workflows/*.yml`, which lands here as `.github/.github/workflows/*.yml`
- depth 2. GitHub only reads `.github/workflows/` at a repository's root, so
nothing inside a mirrored tree ever runs.

Symlinks are dropped rather than followed. A link can name a path outside the
mirror, and following one would write arbitrary content into this repository's
history; the organization has no legitimate use for one.

Usage:
    python3 scripts/mirror.py --org vortaforge --apply
    python3 scripts/mirror.py --org vortaforge            # dry run
    python3 scripts/mirror.py --org vortaforge --check    # 1 when stale
"""
from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import discover  # noqa: E402

INDEX = Path("index.json")
ROOT = Path(".")
MANIFEST = ".mirror.json"
# Nothing in a source tree is worth mirroring if it is one of these: they are
# either regenerable or a second copy of history we already have.
SKIP_DIRS = {".git", "__pycache__", ".venv", "node_modules", ".gradle", "build", "dist"}


class MirrorError(RuntimeError):
    pass


def run(args: list[str], *, check: bool = True) -> subprocess.CompletedProcess:
    result = subprocess.run(args, capture_output=True, text=True)
    if check and result.returncode != 0:
        sys.stderr.write(result.stderr.strip() + "\n")
        raise MirrorError(f"{' '.join(args)} failed with exit status {result.returncode}")
    return result


def remote_head(org: str, name: str, branch: str) -> str:
    """The commit at the tip of `branch`, without cloning anything."""
    out = run(["git", "ls-remote", f"https://github.com/{org}/{name}.git",
               f"refs/heads/{branch}"]).stdout
    for line in out.splitlines():
        sha, ref = line.split("\t", 1)
        if ref == f"refs/heads/{branch}":
            return sha.strip()
    # An empty repository lists no refs; there is nothing to mirror.
    return ""


def clone(org: str, name: str, branch: str) -> tuple[Path, str]:
    """Shallow-clone one repository into a temporary directory."""
    tmp = Path(tempfile.mkdtemp(prefix=f"mirror-{name.replace('/', '-')}-"))
    target = tmp / "tree"
    try:
        run(["git", "clone", "--quiet", "--depth", "1", "--single-branch",
             "--branch", branch, "--no-tags",
             f"https://github.com/{org}/{name}.git", str(target)])
    except MirrorError:
        shutil.rmtree(tmp, ignore_errors=True)
        raise
    head = run(["git", "-C", str(target), "rev-parse", "HEAD"]).stdout.strip()
    return target, head


def copy_tree(src: Path, dest: Path, skip_paths: frozenset[str] = frozenset(),
              skip_dirs: set[str] = frozenset()) -> dict:
    """Copy `src` into `dest`, skipping what should not be mirrored.

    Two kinds of exclusion, and they are not interchangeable:

    `skip_paths` names exact files, relative to `src`. It exists for the
    self-mirror: `vorta-core` is one of the repositories being mirrored, and its
    tree contains the mirror trees written by previous runs. Copying those in
    would mirror the mirrors - the first CI run did exactly that and pulled in
    5 350 files - and would nest one level deeper on every run after.

    `skip_dirs` names top-level directories to leave out entirely.
    """
    files = dropped = 0
    total = 0
    written: list[str] = []
    for path in sorted(src.rglob("*")):
        rel = path.relative_to(src)
        parts = rel.parts
        if parts[0] in skip_dirs:
            continue
        if any(p in SKIP_DIRS for p in parts):
            continue
        if str(rel) in skip_paths:
            continue
        if path.is_symlink():
            dropped += 1
            continue
        if path.is_dir():
            (dest / rel).mkdir(parents=True, exist_ok=True)
            continue
        files += 1
        total += path.stat().st_size
        (dest / rel).parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, dest / rel)
        written.append(str(rel))
    # `written`, not a directory listing: `dest` may also hold this repository's
    # own files (docs/ is both ours and the mirror of vortaforge/docs) and a
    # manifest that claimed them would license the next run to delete them.
    return {"files": files, "bytes": total, "symlinksDropped": dropped,
            "written": written}


def clashes_with_ours(source: Path, dest: Path, managed: bool) -> list[str]:
    """Paths in the incoming tree that would overwrite a file of this repository.

    Mirrors sit at the root, so `docs/` is both this repository's own
    documentation directory and the destination of `vortaforge/docs`. That is
    fine as long as no *file* lands on an existing one: `vortaforge/docs` keeps
    its pages in `docs/` and `vortaforge/.github` keeps its workflows in
    `.github/workflows/`, so they nest to `docs/docs/` and
    `.github/.github/workflows/` and replace nothing.

    Renaming a directory is cheap to recover from; losing
    `docs/OPERATIONS.md` to a sync is not. So the test is per file, and a
    destination that is already a managed mirror has nothing to protect.
    """
    if managed:
        return []
    # Files this directory already holds on behalf of an earlier mirror are not
    # ours to protect: re-running the sync must not report the previous run's
    # output as a collision with itself.
    already = set()
    try:
        manifest = json.loads((dest / MANIFEST).read_text(encoding="utf-8"))
        already = set(manifest.get("paths") or [])
        already.add(MANIFEST)
    except (OSError, json.JSONDecodeError):
        pass

    found = []
    for path in source.rglob("*"):
        rel = path.relative_to(source)
        if str(rel) in already:
            continue
        if path.is_file() and not path.is_symlink() and (dest / rel).exists():
            found.append(str(rel))
    return sorted(found)


def clear(dest: Path) -> None:
    """Remove exactly the files a previous mirror wrote, and nothing else.

    `dest` is a real directory of this repository as soon as a mirrored
    repository shares its name - `docs/` holds this repository's own
    OPERATIONS.md as well as `vortaforge/docs`. Deleting the tree wholesale
    destroys our files, which is what happened the first time this ran.
    So a mirror removes only what its manifest lists.
    """
    manifest = dest / MANIFEST
    try:
        previous = json.loads(manifest.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        previous = {}
    owned = previous.get("paths") or []
    for rel in owned:
        target = dest / rel
        try:
            target.unlink(missing_ok=True)
        except IsADirectoryError:
            pass
    # Directories the mirror created are removed only when empty, deepest first,
    # so a directory that also holds our own files survives.
    for child in sorted((p for p in dest.rglob("*") if p.is_dir()), reverse=True):
        try:
            child.rmdir()
        except OSError:
            pass
    manifest.unlink(missing_ok=True)


def repository_name() -> str:
    """The name of the repository this script is running inside, if it can tell."""
    result = run(["git", "remote", "get-url", "origin"], check=False)
    if result.returncode != 0:
        return ""
    url = result.stdout.strip().removesuffix(".git")
    return url.rstrip("/").rsplit("/", 1)[-1]


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--org", required=True)
    parser.add_argument("--index", type=Path, default=INDEX)
    parser.add_argument("--root", type=Path, default=ROOT)
    parser.add_argument("--only", action="append", default=None,
                        help="mirror just these repositories (repeatable)")
    parser.add_argument("--apply", action="store_true",
                        help="write the mirrored trees and update index.json")
    parser.add_argument("--check", action="store_true",
                        help="exit 1 when a mirror is missing or stale")
    args = parser.parse_args(argv)

    try:
        index = json.loads(args.index.read_text(encoding="utf-8"))
    except FileNotFoundError:
        index = {"org": None, "repositories": [], "mirrors": {}}

    try:
        repos = discover.discover(args.org, include_archived=True)
    except SystemExit as exc:
        sys.stderr.write(f"discovery failed: {exc}\n")
        return 2

    if args.only:
        wanted = set(args.only)
        repos = [r for r in repos if r["name"] in wanted]

    by_name = {r["name"]: r for r in repos}
    names = sorted(by_name)

    self_name = repository_name()
    mirrors = dict(index.get("mirrors", {}))
    stale: list[str] = []
    results: list[dict] = []
    stamp = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")

    for name in names:
        branch = by_name[name].get("defaultBranch") or ""
        if not branch:
            results.append({"repo": name, "skipped": "no default branch"})
            continue

        dest = args.root / name
        try:
            head = remote_head(args.org, name, branch)
        except MirrorError as exc:
            sys.stderr.write(f"mirror: {name}: {exc}\n")
            stale.append(name)
            results.append({"repo": name, "error": str(exc)})
            continue

        if not head:
            results.append({"repo": name, "skipped": "empty repository"})
            continue

        if not args.apply:
            manifest = dest / MANIFEST
            have = {}
            if manifest.is_file():
                try:
                    have = json.loads(manifest.read_text(encoding="utf-8"))
                except json.JSONDecodeError:
                    have = {}
            if have.get("commit") != head:
                stale.append(name)
                results.append({"repo": name,
                                "stale": f"{have.get('commit') or 'absent'} -> {head}"})
            else:
                results.append({"repo": name, "ok": True})
            continue

        if had := mirrors.get(name, {}).get("commit"):
            if had == head and (dest / MANIFEST).is_file():
                results.append({"repo": name, "ok": True, "unchanged": True})
                continue
        source, commit = clone(args.org, name, branch)
        try:
            clash = clashes_with_ours(source, dest, managed=name in mirrors)
            if clash:
                sys.stderr.write(
                    f"mirror: {args.org}/{name} would overwrite {len(clash)} file(s) "
                    f"of this repository, first: {clash[0]}; refusing\n")
                return 2
            if dest.exists():
                clear(dest)
            dest.mkdir(parents=True, exist_ok=True)
            if name == self_name:
                # This repository's tree holds the mirror trees written by
                # previous runs. Copying them in would mirror the mirrors - the
                # first CI run pulled in 5 350 files that way - and would nest a
                # level deeper on every run after.
                #
                # index.json and events.log change on every sync by design; the
                # manifest carries a timestamp. Including them would produce a
                # commit every six hours whose only content is the time.
                record = copy_tree(
                    source, dest,
                    skip_paths=frozenset({MANIFEST, "index.json", "events.log"}),
                    skip_dirs={self_name} | set(mirrors),
                )
            else:
                record = copy_tree(source, dest)
        finally:
            shutil.rmtree(source.parent, ignore_errors=True)

        record["paths"] = sorted(record.pop("written"))
        record.update({
            "repo": f"{args.org}/{name}",
            "branch": branch,
            "commit": commit,
            # No wall clock in the committed tree. `syncedAt` was the one field
            # that differed between two syncs of the same commit, and it turned a
            # concurrent push into an unmergeable conflict in every mirrored
            # directory at once. `commit` already says how fresh the snapshot is.
            "note": "Snapshot of the default branch. Read-only: do not edit here.",
        })
        (dest / MANIFEST).write_text(json.dumps(record, indent=2) + "\n", encoding="utf-8")
        mirrors[name] = {k: record[k] for k in ("branch", "commit", "files", "bytes")}
        results.append(record)

    # A repository that left the organization keeps none of its mirror: a stale
    # copy of a deleted repository is worse than no copy, because it looks live.
    gone = sorted(set(mirrors) - set(names))
    for name in gone:
        stale.append(name)
        try:
            if (args.root / name).exists():
                clear(args.root / name)
        except OSError as exc:
            sys.stderr.write(f"mirror: could not remove {name}/: {exc}\n")
            return 2
        mirrors.pop(name, None)
        results.append({"repo": name, "removed": True})

    summary = {
        "org": args.org,
        "mirrored": len(names),
        "stale": stale,
        "removed": gone,
        "results": results,
    }
    print(json.dumps(summary, indent=2))

    if args.check:
        return 1 if stale else 0

    if args.apply:
        out = dict(index)
        out["mirrors"] = {n: mirrors[n] for n in sorted(mirrors)}

        # Keep the old stamp when the mirrors did not actually move. Writing a
        # fresh timestamp unconditionally meant every scheduled run produced a
        # commit whose only change was the clock.
        before = index.get("mirrors") or {}
        unchanged = json.dumps(before, sort_keys=True) == json.dumps(
            out["mirrors"], sort_keys=True)
        if unchanged and index.get("mirrorsGeneratedAt"):
            stamp = index["mirrorsGeneratedAt"]
        # `mirrorsGeneratedAt` moves on every run by definition, so writing it
        # unconditionally produced a commit every six hours whose only content
        # was the time. When nothing else changed, the previous stamp is kept and
        # the file is left byte-identical.
        rendered = json.dumps({**out, "mirrorsGeneratedAt": stamp}, indent=2) + "\n"
        previous = (args.index.read_text(encoding="utf-8")
                    if args.index.exists() else "")
        if rendered != previous:
            args.index.write_text(rendered, encoding="utf-8")
    elif stale:
        print(f"dry run: {len(stale)} mirror(s) would be written or removed "
              f"(pass --apply to write them)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
