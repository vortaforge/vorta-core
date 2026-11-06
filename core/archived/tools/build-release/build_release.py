#!/usr/bin/env python3
"""Deterministic release builds for the datapacks under packs/.

What this does
--------------
For every pack found under packs/ (a pack root is the directory that holds a
pack.mcmeta, so RTWrapper's nested datapack is found too) it writes one ZIP
to the output directory:

* ``.mcfunction`` files are minified in the release copy only: blank lines
  and full-line comments (lines whose first character is ``#``) are dropped
  and trailing whitespace is trimmed. Command text is otherwise untouched -
  in particular nothing is renamed, so namespaces, public ``api/`` function
  ids and scoreboard/storage identifiers are identical to the source pack
  (renaming them would break existing worlds; see docs/MAINTAINER_GUIDE.md).
* ``_vc_origin.mcfunction`` provenance files are copied verbatim, so a
  release ZIP still identifies the pack it was built from.
* Ward test folders (``data/<namespace>/test/``) are excluded: they contain
  the Ward mod's ``assert``/``await`` commands, which are not vanilla and
  have no place in a runtime pack.
* Everything else (JSON, pack.mcmeta, images, ...) is copied byte for byte.

The ZIPs are deterministic (sorted entries, fixed timestamp, fixed file
mode), so the same source always produces the same bytes. Two sidecar files
are written next to the ZIPs:

* ``SHA256SUMS.txt`` - one SHA-256 per ZIP, for release verification.
* ``dynamic-surfaces.json`` - an inventory of every place a pack executes a
  command string that is not literal source text (whole-command macros,
  ``run $(...)``, dynamic ``function`` dispatch and storage-fed command
  blocks). It is a review aid: it lists the surfaces that the runtime
  dynamic-command gate exists for. See docs/dynamic-command-gate.md.

What this deliberately does not do
-----------------------------------
No obfuscation, no name mangling, no encryption and no dead-code injection.
The source tree stays plain, readable and auditable, which is the only
honest defence against "is this pack malicious?" false positives - and the
only posture compatible with this repository's Unlicense release. The
minified ZIP is an optimisation of the release artifact, not a way to hide
what the code does: anyone can reproduce it from the source with this
script and compare the SHA-256.

Usage
-----
    python3 scripts/build_release.py                 # build all packs
    python3 scripts/build_release.py --pack DailyBonus
    python3 scripts/build_release.py --list          # list discovered packs
    python3 scripts/build_release.py --check         # determinism check only

Nothing here starts, contacts or needs a Minecraft server.
"""

import argparse
import hashlib
import json
import os
import re
import shutil
import sys
import tempfile
import zipfile

FIXED_ZIP_DATE = (1980, 1, 1, 0, 0, 0)
SKIP_NAMES = {".DS_Store", "Thumbs.db"}
SKIP_DIRS = {"__pycache__", ".git", "build", ".gradle", "node_modules"}

DYNAMIC_PATTERNS = (
    ("whole_command_macro", re.compile(r"^\$\$\(")),
    ("run_macro_argument", re.compile(r"\brun\s+\$\(")),
    ("dynamic_function_dispatch", re.compile(r"^\$.*\bfunction\s+\S*\$\(")),
    ("storage_fed_command_block", re.compile(r"\bCommand\s+set\s+from\s+storage\b")),
)


def minify_mcfunction(text):
    """Drop blank lines and full-line comments; trim trailing whitespace.

    A ``#`` anywhere else (inside a JSON text component, a selector, a
    scoreboard fake-player name such as ``#foo``) is command text and is
    preserved, because only lines that *start* with ``#`` are comments.
    Leading whitespace is also removed: .mcfunction has no indentation
    semantics, and a macro line must start with ``$`` to work at all.
    """
    out = []
    for line in text.splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        out.append(line.strip())
    return "\n".join(out) + ("\n" if out else "")


def is_ward_test_path(rel_parts):
    """True for data/<namespace>/test/** relative to a pack root."""
    return len(rel_parts) >= 3 and rel_parts[0] == "data" and rel_parts[2] == "test"


def find_pack_roots(packs_dir):
    """Return [(slug, root_path), ...] for every pack.mcmeta under packs_dir."""
    roots = []
    for dirpath, dirnames, filenames in os.walk(packs_dir):
        dirnames[:] = sorted(d for d in dirnames if d not in SKIP_DIRS)
        if "pack.mcmeta" in filenames:
            roots.append(dirpath)
    packs = []
    seen = {}
    for root in sorted(roots):
        rel = os.path.relpath(root, packs_dir)
        parts = [p for p in rel.split(os.sep) if p not in ("", ".")]
        # packs/<name> -> <name>; packs/RTWrapper/datapack/RTWrapper-Datapack
        # -> RTWrapper (first component), with a suffix only on collision so
        # two nested packs under one container could never silently merge.
        slug = parts[0] if parts else os.path.basename(root)
        if slug in seen:
            slug = "-".join(parts)
        seen[slug] = root
        packs.append((slug, root))
    return packs


def iter_pack_files(root):
    """Yield (abs_path, rel_parts) for every file that belongs in the ZIP."""
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = sorted(d for d in dirnames if d not in SKIP_DIRS)
        for name in sorted(filenames):
            if name in SKIP_NAMES or name.endswith(".pyc"):
                continue
            path = os.path.join(dirpath, name)
            rel_parts = os.path.relpath(path, root).split(os.sep)
            if is_ward_test_path(rel_parts):
                continue
            yield path, rel_parts


def scan_dynamic_surfaces(root):
    """List dynamic command-execution lines in one pack (source, unminified)."""
    hits = []
    for path, rel_parts in iter_pack_files(root):
        if not path.endswith(".mcfunction"):
            continue
        with open(path, "r", encoding="utf-8", errors="strict") as fh:
            for lineno, line in enumerate(fh, 1):
                stripped = line.strip()
                if not stripped or stripped.startswith("#"):
                    continue
                for kind, pattern in DYNAMIC_PATTERNS:
                    if pattern.search(stripped):
                        hits.append({
                            "file": "/".join(rel_parts),
                            "line": lineno,
                            "kind": kind,
                            "text": stripped,
                        })
                        break
    return hits


def file_bytes_for_zip(path, rel_parts):
    with open(path, "rb") as fh:
        raw = fh.read()
    # Provenance files are copied verbatim on purpose (see module docstring).
    if path.endswith(".mcfunction") and rel_parts[-1] != "_vc_origin.mcfunction":
        return minify_mcfunction(raw.decode("utf-8")).encode("utf-8")
    return raw


def build_pack_zip(root, zip_path):
    with zipfile.ZipFile(zip_path, "w") as zf:
        for path, rel_parts in iter_pack_files(root):
            info = zipfile.ZipInfo("/".join(rel_parts), date_time=FIXED_ZIP_DATE)
            info.create_system = 3
            info.external_attr = (0o644 & 0xFFFF) << 16
            info.compress_type = zipfile.ZIP_DEFLATED
            zf.writestr(info, file_bytes_for_zip(path, rel_parts), compresslevel=9)
    return zip_path


def sha256_of(path):
    digest = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(65536), b""):
            digest.update(chunk)
    return digest.hexdigest()


def build_all(packs_dir, out_dir, only=None):
    """Build every (or every selected) pack. Returns {slug: zip_path}."""
    packs = find_pack_roots(packs_dir)
    if only:
        known = {slug for slug, _ in packs}
        unknown = [slug for slug in only if slug not in known]
        if unknown:
            raise SystemExit("unknown pack(s): %s (known: %s)"
                             % (", ".join(sorted(unknown)), ", ".join(sorted(known))))
        packs = [(slug, root) for slug, root in packs if slug in only]
    os.makedirs(out_dir, exist_ok=True)
    built = {}
    surfaces = {}
    for slug, root in packs:
        zip_path = os.path.join(out_dir, slug + ".zip")
        build_pack_zip(root, zip_path)
        built[slug] = zip_path
        surfaces[slug] = scan_dynamic_surfaces(root)
    with open(os.path.join(out_dir, "SHA256SUMS.txt"), "w", encoding="utf-8") as fh:
        for slug in sorted(built):
            fh.write("%s  %s.zip\n" % (sha256_of(built[slug]), slug))
    inventory = {
        "generated_by": "scripts/build_release.py",
        "note": ("Dynamic command-execution surfaces found in the source "
                 "packs. Review aid only; see docs/dynamic-command-gate.md."),
        "packs": surfaces,
    }
    with open(os.path.join(out_dir, "dynamic-surfaces.json"), "w", encoding="utf-8") as fh:
        json.dump(inventory, fh, indent=2, sort_keys=True)
        fh.write("\n")
    return built


def check_deterministic(packs_dir, only=None):
    """Build twice into temp dirs; fail if any ZIP differs or if the
    minifier is not idempotent on any source file."""
    problems = []
    for slug, root in find_pack_roots(packs_dir):
        if only and slug not in only:
            continue
        for path, rel_parts in iter_pack_files(root):
            if not path.endswith(".mcfunction"):
                continue
            with open(path, "r", encoding="utf-8") as fh:
                once = minify_mcfunction(fh.read())
            if minify_mcfunction(once) != once:
                problems.append("minify not idempotent: %s" % path)
    dir_a = tempfile.mkdtemp(prefix="release-check-a-")
    dir_b = tempfile.mkdtemp(prefix="release-check-b-")
    try:
        built_a = build_all(packs_dir, dir_a, only=only)
        built_b = build_all(packs_dir, dir_b, only=only)
        for slug in sorted(built_a):
            if sha256_of(built_a[slug]) != sha256_of(built_b[slug]):
                problems.append("non-deterministic ZIP: %s" % slug)
    finally:
        shutil.rmtree(dir_a, ignore_errors=True)
        shutil.rmtree(dir_b, ignore_errors=True)
    return problems


def main(argv=None):
    script_dir = os.path.dirname(os.path.abspath(__file__))
    repo_root = os.path.dirname(script_dir)
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--packs-dir", default=os.path.join(repo_root, "packs"))
    parser.add_argument("--out", default=os.path.join(repo_root, "build", "release"))
    parser.add_argument("--pack", action="append", dest="packs",
                        help="build only this pack slug (repeatable)")
    parser.add_argument("--list", action="store_true", help="list discovered packs and exit")
    parser.add_argument("--check", action="store_true",
                        help="verify determinism and minifier idempotence, write nothing")
    args = parser.parse_args(argv)

    if args.list:
        for slug, root in find_pack_roots(args.packs_dir):
            print("%s\t%s" % (slug, os.path.relpath(root, repo_root)))
        return 0
    if args.check:
        problems = check_deterministic(args.packs_dir, only=args.packs)
        for problem in problems:
            print("FAIL: %s" % problem, file=sys.stderr)
        print("release build check: %s" % ("FAILED" if problems else "passed"))
        return 1 if problems else 0
    built = build_all(args.packs_dir, args.out, only=args.packs)
    for slug in sorted(built):
        print("%s  %s" % (sha256_of(built[slug]), built[slug]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
