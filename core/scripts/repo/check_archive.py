#!/usr/bin/env python3
"""Validate archived/archive.json (stdlib only, no network, no code execution).

This is the authoritative checker for the archive registry (schema_version 2).
It is deliberately strict: the whole point of archived/ is that nothing in it
can come back to life by accident.

Checks
------
Registry shape
  * schema_version is 2, top level is an object, projects is an array.
  * Required fields present, unknown fields rejected, enums valid, unique ids,
    archived_on is YYYY-MM-DD, reason is non-empty.
  * known_issues is an array of strings.

Hard-disable rules (the "kill switch")
  * Every entry must have "disarmed": true. A missing "disarmed" is an error,
    not a default, so a registry copied from schema_version 1 cannot silently
    re-enable archived code.
  * Everything that is, generates, lints, tests or serves datapacks must carry
    "is_datapack": true and be disarmed. Datapack programme retirement is not
    opt-out.

Location rules
  * "path" must exist, must stay inside the repository, and must start with
    "archived/". Code under packs/, mods/, scripts/, examples/ or .github/ is
    live code and cannot be registered as archived.
  * "original_path", when set, must NOT exist any more (the migration must be
    complete).
  * No workflow file may exist anywhere under archived/ - a .github/workflows
    path inside archived/ would run on GitHub.
  * settings.gradle must not scan archived/ (it would re-add archived
    subprojects to the Gradle build).

Completeness rules
  * Every directory under archived/packs/ and every project directory under
    archived/tools/ has exactly one registry entry pointing at it, and every
    registry path under archived/ exists (bijection).
  * packs/ must be empty (or absent) apart from its own README.md/.gitkeep:
    the datapack programme is retired.
  * packs/merge-manifest.json must not exist live; if it does, its "include"
    list must be empty.
  * A live scripts/ or examples/ datapack tool path must not exist
    (see LIVE_DATAPACK_PATHS).

Exit code 1 on any error. Warnings never fail unless --strict is passed.

Usage
-----
    python3 scripts/repo/check_archive.py            # human output
    python3 scripts/repo/check_archive.py --json     # machine output
    python3 scripts/repo/check_archive.py --strict   # warnings become failures
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
REG = ROOT / "archived" / "archive.json"
SCHEMA_VERSION = 2

REQUIRED = ["id", "name", "kind", "status", "archived_on", "reason",
            "last_version", "license", "deploy", "successor"]
OPTIONAL = {"minecraft", "path", "source_url", "known_issues",
            "original_path", "disarmed", "is_datapack", "quality_score",
            "pack_format", "description", "last_commit"}
ALLOWED = set(REQUIRED) | OPTIONAL

KINDS = {"datapack", "mod", "resourcepack", "script", "other"}
STATUS = {"archived", "frozen", "superseded"}
DEPLOY = {"not_recommended", "review_required", "ok"}

# Directories that hold live, buildable, shippable code. Archived entries may
# never point here.
LIVE_ROOTS = ("packs", "mods", "scripts", "examples", "build-logic", ".github")

# Paths that must not exist as live datapack tooling any more.
LIVE_DATAPACK_PATHS = (
    "scripts/dpgen",
    "scripts/gui_generator",
    "scripts/datapack_lint",
    "scripts/lint_datapacks.sh",
    "scripts/ward_ci.sh",
    "scripts/ward_guard.py",
    "mods/datapack-blocker",
    "examples/template-datapack",
    ".github/workflows/ward.yml",
)

FORBIDDEN_IN_ARCHIVED = (".github",)  # a workflow under archived/ would run


def rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def main(argv: list[str]) -> int:
    as_json = "--json" in argv
    strict = "--strict" in argv
    errors: list[str] = []
    warnings: list[str] = []

    def err(msg: str) -> None:
        errors.append(msg)

    def warn(msg: str) -> None:
        warnings.append(msg)

    if not REG.is_file():
        print(f"[check_archive] ERROR {rel(REG)} is missing.")
        return 1
    try:
        data = json.loads(REG.read_text(encoding="utf-8"))
    except Exception as exc:  # noqa: BLE001 - report, never crash
        print(f"[check_archive] ERROR cannot parse {rel(REG)}: {exc}")
        return 1
    if not isinstance(data, dict):
        print(f"[check_archive] ERROR {rel(REG)}: top level must be an object.")
        return 1
    if data.get("schema_version") != SCHEMA_VERSION:
        err(f"schema_version must be {SCHEMA_VERSION} (found {data.get('schema_version')!r}); "
            f"see archived/archive.schema.json")
    projects = data.get("projects")
    if not isinstance(projects, list):
        print("[check_archive] ERROR 'projects' must be an array.")
        return 1

    seen: set[str] = set()
    registered_paths: set[str] = set()

    for i, p in enumerate(projects):
        if not isinstance(p, dict):
            err(f"projects[{i}]: must be an object")
            continue
        tag = f"projects[{i}] ({p.get('id', '?')})"

        for key in REQUIRED:
            if key not in p:
                err(f"{tag}: missing required field '{key}'")
        for key in p:
            if key not in ALLOWED:
                err(f"{tag}: unknown field '{key}'")

        pid = p.get("id")
        if not isinstance(pid, str) or not re.fullmatch(r"[a-z0-9][a-z0-9._-]*", pid):
            err(f"{tag}: id must match ^[a-z0-9][a-z0-9._-]*$")
        elif pid in seen:
            err(f"{tag}: duplicate id '{pid}'")
        else:
            seen.add(pid)

        if p.get("kind") not in KINDS:
            err(f"{tag}: bad kind {p.get('kind')!r} (one of {sorted(KINDS)})")
        if p.get("status") not in STATUS:
            err(f"{tag}: bad status {p.get('status')!r}")
        if p.get("deploy") not in DEPLOY:
            err(f"{tag}: bad deploy {p.get('deploy')!r}")
        if not re.fullmatch(r"\d{4}-\d{2}-\d{2}", str(p.get("archived_on", ""))):
            err(f"{tag}: archived_on must be YYYY-MM-DD")
        reason = p.get("reason")
        if not isinstance(reason, str) or len(reason.strip()) < 20:
            err(f"{tag}: reason must be a meaningful sentence (>= 20 chars); "
                f"every retirement has a reason")
        if "known_issues" in p:
            issues = p["known_issues"]
            if not isinstance(issues, list) or not all(isinstance(x, str) for x in issues):
                err(f"{tag}: known_issues must be an array of strings")

        # --- hard-disable (kill switch) ---------------------------------
        if "disarmed" not in p:
            err(f"{tag}: missing 'disarmed' - schema v2 requires an explicit "
                f"true so a v1 registry cannot silently re-enable archived code")
        elif p["disarmed"] is not True:
            err(f"{tag}: 'disarmed' must be true; nothing in archived/ may be "
                f"built, merged, zipped or executed")
        # Anything that is / generates / lints / tests / serves a datapack must
        # say so. A resource pack is not a datapack, so is_datapack=false is
        # allowed there; kind "datapack" always requires the flag.
        if p.get("kind") == "datapack" and p.get("is_datapack") is not True:
            err(f"{tag}: kind 'datapack' must set \"is_datapack\": true")
        if p.get("is_datapack") not in (True, False, None):
            err(f"{tag}: is_datapack must be a boolean")

        # --- location ----------------------------------------------------
        path = p.get("path")
        if path is not None:
            if not isinstance(path, str):
                err(f"{tag}: path must be a string or null")
            else:
                target = (ROOT / path).resolve()
                if target != ROOT and ROOT not in target.parents:
                    err(f"{tag}: path escapes the repository")
                elif not target.exists():
                    err(f"{tag}: path '{path}' does not exist")
                elif not path.startswith("archived/"):
                    err(f"{tag}: path '{path}' must start with 'archived/' - live "
                        f"code cannot be registered as archived")
                else:
                    registered_paths.add(path.rstrip("/"))
                    parts = Path(path).parts
                    if parts[0] in LIVE_ROOTS:
                        err(f"{tag}: path '{path}' is under a live root")
                    if any(part in FORBIDDEN_IN_ARCHIVED for part in parts):
                        err(f"{tag}: no .github/ path may live under archived/")
                    if "/.github/" in f"/{path}/" or path.endswith(".yml") and "/workflows/" in path:
                        err(f"{tag}: '{path}' looks like a workflow; workflows must not be "
                            f"archived into a runnable location")

        original = p.get("original_path")
        if original is not None:
            if not isinstance(original, str):
                err(f"{tag}: original_path must be a string or null")
            elif (ROOT / original).exists():
                err(f"{tag}: original_path '{original}' still exists - the move to "
                    f"archived/ is incomplete")
            elif Path(original).parts[0] not in LIVE_ROOTS:
                err(f"{tag}: original_path '{original}' should name the old live location")

        # --- successor / source -----------------------------------------
        succ = p.get("successor")
        if succ is not None and not isinstance(succ, str):
            err(f"{tag}: successor must be a string or null")
        elif succ:
            if succ == pid:
                err(f"{tag}: successor cannot be itself")
            elif p.get("kind") == "datapack":
                # A datapack is replaced by a pack, so the name is resolved
                # under packs/.
                if not (ROOT / "packs" / succ).exists():
                    warn(f"{tag}: successor '{succ}' is not a live pack under packs/ "
                         f"(expected while the datapack programme is retired)")
            else:
                # Anything else names a real path (a script, a mod directory).
                # A successor that does not exist is a dangling pointer: the
                # entry says "use that instead" and there is nothing there.
                candidate = ROOT / succ
                if not candidate.exists():
                    err(f"{tag}: successor '{succ}' does not exist")

    # --- completeness: archived/packs/** and archived/tools/** registered --
    for base in ("archived/packs", "archived/tools"):
        base_dir = ROOT / base
        if not base_dir.is_dir():
            continue
        for child in sorted(base_dir.iterdir()):
            if not child.is_dir():
                continue
            child_rel = rel(child)
            if child_rel not in registered_paths:
                err(f"{child_rel}: directory exists but has no archive.json entry")

    # --- the live tree must not contradict the registry -------------------
    packs_dir = ROOT / "packs"
    if packs_dir.is_dir():
        allowed = {"README.md", ".gitkeep"}
        leftovers = sorted(d.name for d in packs_dir.iterdir() if d.name not in allowed)
        if leftovers:
            err(f"packs/ is not empty ({', '.join(leftovers)}); live datapack "
                f"content must be archived and registered")

    manifest = ROOT / "packs" / "merge-manifest.json"
    if manifest.is_file():
        try:
            inc = json.loads(manifest.read_text(encoding="utf-8")).get("include", [])
        except Exception as exc:  # noqa: BLE001
            err(f"packs/merge-manifest.json is unreadable: {exc}")
        else:
            if isinstance(inc, list) and inc:
                err(f"packs/merge-manifest.json still includes {inc}; the merge "
                    f"manifest moved to archived/merge-manifest.json")

    for live in LIVE_DATAPACK_PATHS:
        if (ROOT / live).exists():
            err(f"live datapack tooling '{live}' still exists; it was archived "
                f"and must not be resurrected")

    settings = ROOT / "settings.gradle"
    if settings.is_file() and re.search(r"['\"]archived['\"]", settings.read_text(encoding="utf-8")):
        err("settings.gradle scans 'archived' - archived subprojects must stay "
            "out of the Gradle build")

    # --- report ----------------------------------------------------------
    if as_json:
        print(json.dumps({"projects": len(seen), "errors": errors,
                          "warnings": warnings}, indent=2, ensure_ascii=False))
    else:
        for w in warnings:
            print(f"[check_archive] warn: {w}")
        for e in errors:
            print(f"[check_archive] ERROR {e}")
        print(f"[check_archive] {len(seen)} project(s), {len(errors)} error(s), "
              f"{len(warnings)} warning(s)")
    if errors:
        return 1
    if strict and warnings:
        print(f"[check_archive] --strict: {len(warnings)} warning(s) treated as failures")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
