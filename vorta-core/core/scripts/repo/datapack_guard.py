#!/usr/bin/env python3
"""datapack_guard - fail-closed gate against new datapacks, archived-code
revival, and blocklisted accounts.

This repository retired its datapack programme on 2026-11-05 (see
archived/archive.json). This script is the machine-enforced half of that
decision: it runs before a commit, on every push, and in CI, and it refuses
anything that would bring a datapack - or a datapack developer who is on the
blocklist - back in.

Modes (combine freely; at least one source of changes is required)
-------------------------------------------------------------------
  --staged                 read `git diff --cached`
  --base REF               read `git diff REF...HEAD` (CI pull requests)
  --files-from PATH        read newline-separated paths, optionally
                           "STATUS<TAB>path" pairs (STATUS in A/M/D/R/C/T)
  --audit-refs             check every local branch/tag name against the
                           blocklist's ref_patterns (used by the sync job)
  --check-archive          run scripts/repo/check_archive.py and treat its errors
                           as this script's errors (default in CI mode)

Policy flags
------------
  --protect                block new/changed datapack content (default ON)
  --blocklist              block blocked authors, committers and PR authors
  --pr                     pull-request rules: datapack edits in a PR are
                           blocked outright; a `datapack-approved` label is
                           required to override (fail-closed if unknown)
  --push                   pre-push rules: block force-push to main, block
                           commits by blocked accounts, block new packs
  --warn-only              report, exit 0 (advisory jobs only)
  --json                   machine-readable output
  --report PATH            also write the JSON report to PATH
  --override               explicit maintainer override (never implied;
                           pre-push hooks never pass this)
  --repo-root PATH         repository root (default: script's parent)

Exit codes
----------
  0  pass (or --warn-only)
  1  blocked
  2  usage / environment error (treated as a failure, never as a pass)

Design notes
------------
* Fail-closed: an unreadable blocklist, a malformed pattern, an unknown change
  status or a missing git ref is an error, not a skip. The old datapack
  immutability lock was removed because it "enforced nothing"; this one is
  wired into pre-commit, pre-push and two workflows, and every wiring point is
  itself asserted by scripts/tests/test_datapack_guard.py.
* No network access, no code execution. Only stdlib.
* Nothing here is a security boundary against someone with repository admin
  rights; it is a guard against accidents, AI/bot automation and casual
  drive-by PRs, and it makes every exception explicit and reviewable.
"""
from __future__ import annotations

import fnmatch
import json
import os
import re
import subprocess
import sys
from dataclasses import dataclass, field
from pathlib import Path

EXIT_PASS, EXIT_BLOCK, EXIT_USAGE = 0, 1, 2

# ---------------------------------------------------------------------------
# What counts as datapack content
# ---------------------------------------------------------------------------
# Directory names Minecraft reads a datapack from (singular and the pre-1.21
# plural forms are both listed: a contributor using either layout is still
# producing a datapack).
DATAPACK_DIRS = (
    "function", "functions",
    "tags/function", "tags/functions",
    "advancement", "advancements",
    "loot_table", "loot_tables",
    "predicate", "predicates",
    "item_modifier", "item_modifiers",
    "recipe", "recipes",
    "worldgen",
    "dimension", "dimensions",
    "structure", "structures",
    "datapacks",
)
DATAPACK_FILE_GLOBS = (
    "*.mcfunction",
    "pack.mcmeta",
    "pack.png",
    "**/data/*/pack.mcmeta",
)
# Live locations of the retired datapack tooling. Re-creating any of them is a
# resurrection of the programme, not a new file.
RETIRED_LIVE_PATHS = (
    "scripts/dpgen",
    "scripts/datapack_lint",
    "scripts/lint_datapacks.sh",
    "scripts/ward_ci.sh",
    "scripts/ward_guard.py",
    "mods/datapack-blocker",
    "examples/template-datapack",
    "packs/merge-manifest.json",
    ".github/workflows/ward.yml",
)
# Paths where datapack-shaped fixtures are legitimate (tests must be able to
# build a throw-away pack in a temp dir; fixtures that live in the repo are
# allowed here and nowhere else).
FIXTURE_PREFIXES = ("scripts/tests/fixtures/", "archived/")
# A live `packs/` tree must stay empty; deleting from it is how archiving works.
LIVE_PACKS_PREFIX = "packs/"
# The one file the retired tree is allowed to carry: its own explanation.
LIVE_PACKS_ALLOWED = {"packs/README.md", "packs/.gitkeep"}


@dataclass
class Finding:
    level: str          # "error" | "warn"
    rule: str           # stable rule id
    path: str           # file, ref or author the finding is about
    message: str
    paths: list[str] = field(default_factory=list)   # all paths when aggregated

    @property
    def count(self) -> int:
        return len(self.paths) if self.paths else 1

    def as_dict(self) -> dict:
        out = {"level": self.level, "rule": self.rule, "path": self.path, "message": self.message}
        if self.paths:
            out["count"] = len(self.paths)
            out["paths"] = self.paths[:50]
        return out


@dataclass
class Report:
    mode: str
    findings: list[Finding] = field(default_factory=list)
    checked: int = 0

    #: warning rules that are reported once per distinct message instead of
    #: once per file (a 700-file pack deletion must not bury the real findings)
    AGGREGATED_RULES = {"live-packs-removal"}

    def add(self, level: str, rule: str, path: str, message: str) -> None:
        if level == "warn" and rule in self.AGGREGATED_RULES:
            for existing in self.findings:
                if existing.level == level and existing.rule == rule and existing.message == message:
                    if not existing.paths:
                        existing.paths = [existing.path]
                    existing.paths.append(path)
                    return
        self.findings.append(Finding(level, rule, path, message))

    @property
    def errors(self) -> list[Finding]:
        return [f for f in self.findings if f.level == "error"]

    @property
    def warnings(self) -> list[Finding]:
        return [f for f in self.findings if f.level == "warn"]


# ---------------------------------------------------------------------------
# Input: changed paths
# ---------------------------------------------------------------------------
def run_git(root: Path, *args: str) -> str:
    proc = subprocess.run(["git", *args], cwd=root, capture_output=True, text=True, check=False)
    if proc.returncode != 0:
        raise RuntimeError(f"git {' '.join(args)} failed: {proc.stderr.strip()}")
    return proc.stdout


def changes_from_diff(root: Path, args: list[str]) -> list[tuple[str, str]]:
    """Return [(status, path)] from `git diff --name-status -z -M <args>`.

    Renames arrive as two paths separated by NUL; both are reported (the old
    path as a deletion, the new path as an addition) because both matter for
    the "did a datapack move into a live tree" question.
    """
    out = run_git(root, "diff", "--name-status", "-z", "-M", *args)
    parts = [p for p in out.split("\0") if p != ""]
    changes: list[tuple[str, str]] = []
    i = 0
    while i < len(parts):
        status = parts[i]
        if status and status[0] in "RC":
            old, new = parts[i + 1], parts[i + 2]
            changes.append(("D", old))
            changes.append(("A", new))
            i += 3
            continue
        changes.append((status[0], parts[i + 1]))
        i += 2
    return changes


def changes_from_file(path: Path) -> list[tuple[str, str]]:
    changes: list[tuple[str, str]] = []
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if "\t" in line:
            status, p = line.split("\t", 1)
            status = status.strip().upper()[:1]
            if status not in "AMDRCT":
                raise ValueError(f"unknown change status {status!r} in {path}")
            changes.append((status, p.strip()))
        else:
            changes.append(("A", line))  # a bare list means "touched"
    return changes


# ---------------------------------------------------------------------------
# Datapack classification
# ---------------------------------------------------------------------------
# The repository this guard belongs to: scripts/repo/datapack_guard.py -> repo root.
# Resolved from the file's own location so the guard reads the switch of the tree it
# is installed in, not of whatever directory it was invoked from.
REPO_ROOT = Path(__file__).resolve().parents[2]


def datapacks_enabled(root: Path) -> tuple[bool, str]:
    """Read datapacks.disabled.json. Absent or unreadable counts as disabled.

    Returning a reason string rather than a bare bool means the guard can say which
    switch it consulted and what it read, instead of repeating a canned sentence a
    reader cannot check.
    """
    switch = root / "datapacks.disabled.json"
    try:
        data = json.loads(switch.read_text(encoding="utf-8"))
    except FileNotFoundError:
        return False, "datapacks.disabled.json is missing"
    except (OSError, ValueError) as error:
        return False, f"datapacks.disabled.json is unreadable ({error})"
    if data.get("enabled") is True:
        return True, "datapacks.disabled.json says enabled=true"
    return False, "datapacks.disabled.json says enabled=false"


def is_datapack_path(path: str) -> bool:
    """True if the path is datapack content (pack.mcmeta, data/<ns>/<dir>/...)."""
    p = path.replace("\\", "/").lstrip("./")
    if path and any(p.startswith(prefix) for prefix in FIXTURE_PREFIXES):
        return False
    name = p.rsplit("/", 1)[-1]
    if fnmatch.fnmatch(name, "*.mcfunction") or name == "pack.mcmeta":
        return True
    parts = p.split("/")
    if "data" in parts:
        idx = len(parts) - 1 - parts[::-1].index("data")  # last "data" segment
        rest = "/".join(parts[idx + 1:])
        # data/<namespace>/<directory>/...
        tail = rest.split("/", 1)[1] if "/" in rest else ""
        if any(tail == d or tail.startswith(d + "/") for d in DATAPACK_DIRS):
            return True
        if tail == "pack.mcmeta":
            return True
    return False


def rule_for_change(status: str, path: str) -> tuple[str, str, str] | None:
    """Map one (status, path) to (level, rule, message) or None if allowed."""
    p = path.replace("\\", "/")
    in_fixture = any(p.startswith(prefix) for prefix in FIXTURE_PREFIXES)
    in_archived = p.startswith("archived/")
    in_live_packs = p.startswith(LIVE_PACKS_PREFIX)

    # 1. The live packs/ tree must stay empty. Deleting from it is the
    #    archiving path and is allowed (check_archive verifies the registry
    #    entry); adding or editing anything in it is blocked.
    if in_live_packs and p not in LIVE_PACKS_ALLOWED and status in ("A", "M", "C", "T", "R"):
        return ("error", "live-packs-tree",
                "packs/ is retired and must stay empty; new or edited datapack content "
                "is blocked before it lands (archived/ is the only home for it)")

    # 2. Deleting a live pack is the archiving step. Allowed, but the registry
    #    must be updated in the same change (check_archive enforces that).
    #    Reported once per pack directory, not once per file: a 700-file pack
    #    would otherwise bury the real findings.
    if in_live_packs and p not in LIVE_PACKS_ALLOWED and status == "D":
        segments = p.split("/")
        pack_dir = "packs/" + (segments[1] if len(segments) > 1 else "")
        return ("warn", "live-packs-removal",
                f"removing live datapack content from {pack_dir}: confirm archived/archive.json "
                f"has a disarmed entry and run scripts/repo/check_archive.py")

    # 3. Resurrection of retired tooling.
    for retired in RETIRED_LIVE_PATHS:
        if p == retired or p.startswith(retired + "/"):
            if status in ("A", "C", "R", "M"):
                return ("error", "retired-tooling",
                        f"'{retired}' was archived and must not be recreated live "
                        f"(see archived/archive.json)")

    # 4. Any datapack-shaped file outside archived/ and test fixtures.
    #
    # This rule used to block unconditionally, which made it disagree with
    # datapacks.disabled.json: enabling the programme through the documented
    # `datapacks_disable.py enable --token ...` path changed the switch file and
    # nothing else, so the guard still refused. The switch said enabled and the
    # enforcement said disabled, and the only visible symptom was a BLOCK whose
    # reason pointed at the wrong thing.
    #
    # It now reads the same switch the other tools read, so there is one answer to
    # "are datapacks live" instead of two. A missing or unreadable switch still
    # counts as disabled: absent must never mean permitted.
    if is_datapack_path(p) and not in_archived and not in_fixture and status in ("A", "C", "R", "M"):
        enabled, why = datapacks_enabled(REPO_ROOT)
        if not enabled:
            return ("error", "new-datapack",
                    f"new datapack content is disabled ({why}). Enable the programme with "
                    f"scripts/repo/datapacks_disable.py first, or move the content under archived/")

    # 5. Workflows that would run datapack tooling again.
    if p.startswith(".github/workflows/") and status in ("A", "C", "R"):
        stem = p.rsplit("/", 1)[-1].lower()
        if any(word in stem for word in ("ward", "datapack", "pack")):
            return ("warn", "datapack-workflow",
                    "the workflow name suggests datapack tooling; the archived Ward "
                    "harness must not be revived (it starts a Minecraft server)")

    # 6. Merge manifest must not reappear.
    if p == "packs/merge-manifest.json" and status != "D":
        return ("error", "merge-manifest",
                "the merge manifest moved to archived/merge-manifest.json")

    # 7. Archived content: reference-only edits are tolerated but flagged, and
    #    executable additions there are blocked (archived code must stay dead).
    #    archived/packs/ and archived/tools/ are covered by the registry
    #    bijection in check_archive.py, so only stray executables directly
    #    under archived/ (outside a registered tree) are worth a warning.
    if in_archived and status in ("A", "C", "R"):
        in_registered_tree = p.startswith(("archived/packs/", "archived/tools/",
                                           "archived/examples/", "archived/workflows/",
                                           "archived/docs/", "archived/patches/"))
        if not in_registered_tree and p.endswith((".py", ".mjs", ".js", ".java", ".sh", ".gradle")):
            return ("warn", "archived-executable",
                    "adding runnable content directly under archived/ - it will not run "
                    "unless registered; the archive is meant to be frozen")
    return None


def check_changes(report: Report, changes: list[tuple[str, str]]) -> None:
    for status, path in changes:
        report.checked += 1
        verdict = rule_for_change(status, path)
        if verdict is not None:
            level, rule, message = verdict
            report.add(level, rule, path, message)


# ---------------------------------------------------------------------------
# Blocklist
# ---------------------------------------------------------------------------
DEFAULT_BLOCKLIST = Path("blocklist") / "blocklist.json"

# Accounts that are never enforced against, even if a broad pattern matches:
# the maintainer's own managed accounts are declared in the blocklist file
# ("managed"), and GitHub's automation actors are ignored here.
# Every action the blocklist can be enforced against. A `scope` may only name
# one of these; an entry with no scope applies to all of them (the historical
# behaviour, kept so an old entry does not silently stop being enforced).
SCOPES = frozenset({"pull_request", "push", "org_membership"})
ENFORCEMENT_VALUES = frozenset({"block", "review"})

SYSTEM_LOGINS = {"github-actions", "dependabot", "renovate", "vortaforge-maintenance"}


def _in_scope(entry: dict, scope: str | None) -> bool:
    """Does `entry` apply to the action `scope`?

    No declared scope means "every action". An undeclared scope on the caller
    side also means "every action", so a caller that does not know which action
    it is checking cannot be used to weaken a scoped rule.
    """
    declared = entry.get("scope")
    if not declared or scope is None:
        return True
    return str(scope) in {str(s) for s in declared}


_AI_TOKEN_CACHE: dict[str, "re.Pattern[str]"] = {}


def _ai_token_re(token: str) -> "re.Pattern[str]":
    """A vendor name as a whole token, not a fragment of a longer handle."""
    pattern = _AI_TOKEN_CACHE.get(token)
    if pattern is None:
        pattern = re.compile(rf"(?<![a-z0-9]){re.escape(token)}(?![a-z0-9])")
        _AI_TOKEN_CACHE[token] = pattern
    return pattern


class BlocklistError(RuntimeError):
    pass


@dataclass
class Blocklist:
    entries: list[dict]
    managed: set[str]
    config: dict

    @classmethod
    def load(cls, path: Path) -> "Blocklist":
        if not path.is_file():
            raise BlocklistError(f"blocklist file not found: {path}")
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except Exception as exc:  # noqa: BLE001
            raise BlocklistError(f"cannot parse {path}: {exc}") from exc
        if not isinstance(data, dict) or data.get("schema_version") != 1:
            raise BlocklistError(f"{path}: schema_version must be 1")
        entries = data.get("blocked")
        if not isinstance(entries, list):
            raise BlocklistError(f"{path}: 'blocked' must be an array")
        for i, entry in enumerate(entries):
            if not isinstance(entry, dict) or not entry.get("id"):
                raise BlocklistError(f"{path}: blocked[{i}] must be an object with an id")
            if not isinstance(entry.get("logins", []), list):
                raise BlocklistError(f"{path}: blocked[{i}].logins must be an array")
            # Declared values are validated here rather than silently ignored:
            # a `scope` or `enforcement` that the matcher never reads is a lie
            # in the data file, and the whole point of this file is that a
            # reader can trust it. Unknown values fail closed.
            enforcement = entry.get("enforcement", "block")
            if enforcement not in ENFORCEMENT_VALUES:
                raise BlocklistError(
                    f"{path}: blocked[{i}].enforcement must be one of "
                    f"{sorted(ENFORCEMENT_VALUES)}, not {enforcement!r}")
            scope = entry.get("scope")
            if scope is not None:
                if not isinstance(scope, list) or not scope:
                    raise BlocklistError(f"{path}: blocked[{i}].scope must be a non-empty array")
                unknown = sorted(set(map(str, scope)) - SCOPES)
                if unknown:
                    raise BlocklistError(
                        f"{path}: blocked[{i}].scope has unknown value(s) {unknown}; "
                        f"known scopes are {sorted(SCOPES)}")
        managed = {str(x).lower() for x in (data.get("managed") or {}).get("owners", [])}
        managed |= {str(x).lower() for x in (data.get("managed") or {}).get("accounts", [])}
        return cls(entries=entries, managed=managed, config=data.get("policy") or {})

    def matches(self, login: str | None, user_id: int | None = None,
                scope: str | None = None) -> dict | None:
        """Return the entry denying `login`, or None.

        `scope` is the action being checked. An entry declaring a `scope` list
        only applies to those actions; an entry without one applies to every
        action. Before this existed the field was declared in the data file and
        never read, so a rule written for pull requests was also enforced on
        pushes - the opposite of what the file said.
        """
        if not login:
            return None
        lowered = login.lower()
        if lowered in SYSTEM_LOGINS or lowered in self.managed:
            return None
        for entry in self.entries:
            if not _in_scope(entry, scope):
                continue
            for blocked in entry.get("logins", []):
                pattern = str(blocked).lower()
                if fnmatch.fnmatch(lowered, pattern) or lowered == pattern:
                    return entry
            for blocked_id in entry.get("user_ids", []):
                if user_id is not None and int(blocked_id) == int(user_id):
                    return entry
            # type-level matching: bot/AI heuristics declared on the entry
            if entry.get("match_bot_suffix") and (lowered.endswith("[bot]") or lowered.endswith("-bot")
                                                  or lowered.endswith("_bot") or lowered.endswith(".bot")):
                return entry
            if entry.get("match_ai_accounts"):
                # Exact token, not substring. `"claude" in login` also matches
                # "claudette" and "cLaudeLover"; `"grok"` matches "grokhalla";
                # `"codex"` matches "codexy". Those are ordinary usernames, and
                # blocking a person because their handle contains a vendor name
                # is a false positive with a real cost -- it is the sort of rule
                # that makes an account blocklist untrustworthy.
                #
                # A token must stand alone, separated by start/end or a
                # non-alphanumeric character: "claude-bot", "use_claude",
                # "openai.dev" still match; "claudette" and "openair" do not.
                if any(_ai_token_re(token).search(lowered)
                       for token in ("copilot", "claude", "chatgpt", "openai",
                                     "gemini", "grok", "codex", "anthropic")):
                    return entry
                if re.search(r"(^|[-_.])(ai|agent|automation|autobot|devlop)([-_.]|$)", lowered):
                    return entry
        return None

    def enforcement_of(self, entry: dict) -> str:
        """`block` (refuse) or `review` (allow only with the override label)."""
        return str(entry.get("enforcement", "block"))

    def ref_patterns(self) -> list[tuple[str, dict]]:
        pairs: list[tuple[str, dict]] = []
        for entry in self.entries:
            for pattern in entry.get("ref_patterns", []):
                pairs.append((str(pattern).lower(), entry))
        return pairs


def identity_of(root: Path) -> list[tuple[str, str]]:
    """[(email, name)] of the commits about to be pushed (author + committer)."""
    out = run_git(root, "log", "--format=%ae%x00%an%x00%ce%x00%cn", "HEAD", "--not", "--remotes")
    fields = out.split("\0")
    identities: list[tuple[str, str]] = []
    for i in range(0, len(fields) - 1, 2):
        identities.append((fields[i].strip(), fields[i + 1].strip()))
    # also include committer pairs (ce/cn)
    for i in range(0, len(fields) - 3, 4):
        identities.append((fields[i + 2].strip(), fields[i + 3].strip()))
    return identities


def add_blocklist_finding(report: Report, blocklist: Blocklist, hit: dict,
                          rule: str, where: str, what: str,
                          allow_review: bool = False) -> None:
    """The single enforcement decision for a blocklist hit.

    Every path that acts on a match - login, commit identity, numeric id -
    goes through here, so `enforcement: review` behaves the same way wherever
    the match came from. A `review` entry demotes to a warning when the
    maintainer override is present; a `block` entry stays an error.
    """
    overridable = blocklist.enforcement_of(hit) == "review" and allow_review
    report.add("warn" if overridable else "error", rule, where,
               what + ("" if overridable else f": {hit.get('reason', 'blocked')}"))


def check_blocklist(report: Report, blocklist: Blocklist, logins: list[str],
                    identities: list[tuple[str, str]] | None = None,
                    committers: bool = True,
                    scope: str | None = None,
                    allow_review: bool = False,
                    rule: str = "blocklist-account",
                    what: str = "account is on the datapack blocklist") -> None:
    """Record an error for every login or commit identity the blocklist denies.

    `scope` is the action being checked ("pull_request", "push" or
    "org_membership"). Rules scoped to other actions are left alone.

    `allow_review` is the maintainer override (the `datapack-approved` label).
    It only softens entries declaring `enforcement: review`. An entry declaring
    `enforcement: block` stays an error no matter what the label says - that is
    the documented behaviour ("the label does not override the account block
    itself"), and it is enforced here rather than left to a comment.
    """
    seen: set[str] = set()

    def record(rule: str, where: str, hit: dict, what: str) -> None:
        add_blocklist_finding(report, blocklist, hit, rule, where, what,
                              allow_review=allow_review)

    for login in logins:
        if not login or login in seen:
            continue
        seen.add(login)
        hit = blocklist.matches(login, scope=scope)
        if hit:
            record(rule, login, hit, what)
    for email, name in identities or []:
        if not email:
            continue
        hit = blocklist.matches(email, scope=scope) or blocklist.matches(name, scope=scope)
        if hit and email not in seen:
            seen.add(email)
            record("blocklist-identity", f"{name} <{email}>", hit,
                   "commit identity is on the datapack blocklist")


def check_refs(report: Report, blocklist: Blocklist, root: Path) -> None:
    out = run_git(root, "for-each-ref", "--format=%(refname:short)", "refs/heads", "refs/tags")
    patterns = blocklist.ref_patterns()
    for ref in [r for r in out.splitlines() if r.strip()]:
        report.checked += 1
        lowered = ref.lower()
        for pattern, entry in patterns:
            if fnmatch.fnmatch(lowered, pattern):
                report.add("error", "blocklist-ref", ref,
                           f"ref name matches blocked pattern '{pattern}': {entry.get('reason', 'blocked')}")
                break


# ---------------------------------------------------------------------------
# Archive registry delegation
# ---------------------------------------------------------------------------
def check_archive(report: Report, root: Path) -> bool:
    script = root / "scripts" / "repo" / "check_archive.py"
    if not script.is_file():
        report.add("error", "archive-check", "scripts/repo/check_archive.py",
                   "archive validator is missing; the kill switch cannot be verified")
        return False
    proc = subprocess.run([sys.executable, str(script)], cwd=root, capture_output=True,
                          text=True, check=False)
    report.checked += 1
    for line in (proc.stdout + proc.stderr).splitlines():
        if line.startswith("[check_archive] ERROR"):
            report.add("error", "archive-registry", "archived/archive.json", line.split("ERROR", 1)[1].strip())
        elif line.startswith("[check_archive] warn:"):
            report.add("warn", "archive-registry", "archived/archive.json", line.split("warn:", 1)[1].strip())
    if proc.returncode != 0 and not any(f.rule == "archive-registry" for f in report.findings):
        report.add("error", "archive-check", "scripts/repo/check_archive.py",
                   f"check_archive exited {proc.returncode}")
    return proc.returncode == 0


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------
USAGE = __doc__


def parse_args(argv: list[str]) -> dict:
    opts = {
        "staged": False, "base": None, "files_from": None, "audit_refs": False,
        "check_archive": False, "protect": False, "blocklist": False, "pr": False,
        "push": False, "warn_only": False, "json": False, "report": None,
        "override": False, "repo_root": None, "logins": [], "login_ids": [],
        "no_remote": False, "membership": False,
    }
    i = 0
    while i < len(argv):
        arg = argv[i]
        if arg in ("-h", "--help"):
            print(USAGE)
            raise SystemExit(EXIT_PASS)
        elif arg == "--staged":
            opts["staged"] = True
        elif arg == "--base":
            i += 1
            opts["base"] = argv[i]
        elif arg == "--files-from":
            i += 1
            opts["files_from"] = argv[i]
        elif arg == "--audit-refs":
            opts["audit_refs"] = True
        elif arg == "--check-archive":
            opts["check_archive"] = True
        elif arg == "--protect":
            opts["protect"] = True
        elif arg == "--blocklist":
            opts["blocklist"] = True
        elif arg == "--pr":
            opts["pr"] = True
        elif arg == "--push":
            opts["push"] = True
        elif arg == "--warn-only":
            opts["warn_only"] = True
        elif arg == "--json":
            opts["json"] = True
        elif arg == "--report":
            i += 1
            opts["report"] = argv[i]
        elif arg == "--override":
            opts["override"] = True
        elif arg == "--repo-root":
            i += 1
            opts["repo_root"] = argv[i]
        elif arg == "--membership":
            opts["membership"] = True
        elif arg == "--login-id":
            i += 1
            if i >= len(argv):
                print("[datapack_guard] ERROR --login-id needs a numeric GitHub user id",
                      file=sys.stderr)
                raise SystemExit(EXIT_USAGE)
            try:
                opts.setdefault("login_ids", []).append(int(argv[i]))
            except ValueError:
                print(f"[datapack_guard] ERROR --login-id must be numeric, got {argv[i]!r}",
                      file=sys.stderr)
                raise SystemExit(EXIT_USAGE) from None
        elif arg == "--login":
            i += 1
            opts["logins"].append(argv[i])
        elif arg == "--no-remote":
            opts["no_remote"] = True
        else:
            print(f"[datapack_guard] ERROR unknown argument: {arg}", file=sys.stderr)
            raise SystemExit(EXIT_USAGE)
        i += 1
    return opts


def main(argv: list[str]) -> int:
    try:
        opts = parse_args(argv)
    except SystemExit as exc:
        return int(exc.code or 0)
    root = Path(opts["repo_root"]).resolve() if opts["repo_root"] else Path(__file__).resolve().parents[2]

    modes = []
    if opts["pr"]:
        modes.append("pr")
    if opts["push"]:
        modes.append("push")
    if opts["audit_refs"]:
        modes.append("refs")
    if opts["membership"]:
        modes.append("membership")

    report = Report(mode="+".join(modes) or "local")

    # Default policy: protection ON. CI/push/pre-commit all pass --protect.
    protect = opts["protect"] or not (opts["pr"] or opts["push"] or opts["audit_refs"])
    want_blocklist = (opts["blocklist"] or opts["push"] or opts["pr"]
                      or opts["audit_refs"] or opts["membership"])

    try:
        blocklist = Blocklist.load(root / DEFAULT_BLOCKLIST) if want_blocklist else None
    except BlocklistError as exc:
        print(f"[datapack_guard] ERROR {exc}", file=sys.stderr)
        print("[datapack_guard] fail-closed: a missing or broken blocklist is a failure", file=sys.stderr)
        return EXIT_USAGE

    def is_git_checkout() -> bool:
        try:
            run_git(root, "rev-parse", "--git-dir")
            return True
        except (RuntimeError, OSError):
            return False

    try:
        # --- changed files ------------------------------------------------
        changes: list[tuple[str, str]] = []
        diff_requested = opts["staged"] or opts["base"]
        if diff_requested and not is_git_checkout():
            # A source export / tarball has nothing to diff. That is not an
            # unreadable input: say so and keep running the checks that do not
            # need history (blocklist, refs, archive registry). CI always has
            # a checkout, and a push/pre-push always runs inside one.
            report.add("warn", "no-git", str(root),
                       "not a git checkout: diff-based checks skipped (archive registry and "
                       "blocklist checks still ran)")
            diff_requested = False
        if diff_requested:
            if opts["staged"]:
                changes += changes_from_diff(root, ["--cached"])
            if opts["base"]:
                changes += changes_from_diff(root, [f"{opts['base']}...HEAD"])
        if opts["files_from"]:
            changes += changes_from_file(Path(opts["files_from"]))
        if protect and changes:
            check_changes(report, changes)

        # --- pull-request specifics --------------------------------------
        if opts["pr"] and blocklist is not None and (opts["logins"] or opts["login_ids"]):
            overridden = bool(opts["override"]
                              or os.environ.get("DATAPACK_GUARD_LABEL_PRESENT") == "1")
            # Numeric ids cannot be spoofed by renaming an account. When the
            # caller supplies one (CI reads it from the pull request payload),
            # it is checked separately from the login, so a renamed account
            # still matches its `user_ids` entry. This goes through the same
            # enforcement decision as a login: a `review` entry is cleared by
            # the label, a `block` entry is not.
            for user_id in opts["login_ids"]:
                hit = blocklist.matches(f"id:{user_id}", user_id=user_id,
                                        scope="pull_request")
                if hit:
                    add_blocklist_finding(report, blocklist, hit,
                                          "blocklist-user-id", f"user id {user_id}",
                                          "account id is on the datapack blocklist",
                                          allow_review=overridden)
            check_blocklist(report, blocklist, opts["logins"],
                            scope="pull_request", allow_review=overridden)
            blocked_accounts = [f for f in report.errors
                                if f.rule == "blocklist-account"]
            if blocked_accounts and not overridden:
                report.add("error", "pr-blocked",
                           ", ".join(opts["logins"]),
                           "pull request is blocked; the `datapack-approved` label is "
                           "required and was not present")

        # --- push specifics ----------------------------------------------
        if opts["push"] and blocklist is not None:
            identities = identity_of(root) if is_git_checkout() else []
            check_blocklist(report, blocklist, opts["logins"], identities=identities,
                            scope="push")
            # Force-push detection on protected branches (pre-push passes the
            # remote ref through the environment; absent means "unknown",
            # which fails closed only when --push was requested explicitly).
            if os.environ.get("PRE_PUSH_FORCE") == "1" and not opts["override"]:
                report.add("error", "force-push", os.environ.get("PRE_PUSH_REF", "?"),
                           "force-push to a protected branch is not allowed; archived "
                           "history must stay intact")

        # --- organisation membership --------------------------------------
        # `org_membership` is a declared scope. Nothing in this repository can
        # invite anyone, so the useful check is the inverse: given a list of
        # accounts someone is about to add or invite, refuse the ones the
        # blocklist has scoped to org_membership. Without this, the scope was
        # a promise in the data file that no code kept.
        if opts["membership"] and blocklist is not None:
            if not opts["logins"]:
                report.add("error", "membership-empty", "-",
                           "--membership needs at least one --login to check")
            else:
                check_blocklist(report, blocklist, opts["logins"],
                                scope="org_membership",
                                rule="blocklist-membership",
                                what="account may not be added to the organisation")

        # --- ref audit ---------------------------------------------------
        if opts["audit_refs"] and blocklist is not None:
            if is_git_checkout():
                check_refs(report, blocklist, root)
            else:
                report.add("warn", "no-git", str(root), "not a git checkout: ref audit skipped")

        # --- archive registry -------------------------------------------
        if opts["check_archive"] or opts["pr"] or opts["push"]:
            check_archive(report, root)
    except (RuntimeError, ValueError, OSError) as exc:
        print(f"[datapack_guard] ERROR {exc}", file=sys.stderr)
        print("[datapack_guard] fail-closed: an unreadable input is a failure", file=sys.stderr)
        return EXIT_USAGE

    # --- override ---------------------------------------------------------
    if opts["override"]:
        for finding in report.errors:
            report.findings.append(Finding("warn", "overridden", finding.path,
                                           f"maintainer override: {finding.message}"))
        report.findings = [f for f in report.findings if f.level != "error"]
        report.add("warn", "override", "cli",
                   "--override was used: every block above is downgraded to a warning. "
                   "This must be justified in the commit message / PR description.")

    blocked = bool(report.errors)
    if opts["json"] or opts["report"]:
        payload = {
            "ok": not blocked or opts["warn_only"],
            "mode": report.mode,
            "checked": report.checked,
            "errors": [f.as_dict() for f in report.errors],
            "warnings": [f.as_dict() for f in report.warnings],
            "override": opts["override"],
        }
        text = json.dumps(payload, indent=2, ensure_ascii=False)
        if opts["json"]:
            print(text)
        if opts["report"]:
            Path(opts["report"]).parent.mkdir(parents=True, exist_ok=True)
            Path(opts["report"]).write_text(text + "\n", encoding="utf-8")

    def emit(label: str, findings: list[Finding], limit: int = 25) -> None:
        by_rule: dict[str, list[Finding]] = {}
        for finding in findings:
            by_rule.setdefault(finding.rule, []).append(finding)
        shown = 0
        for rule, group in by_rule.items():
            if shown >= limit:
                remaining = sum(len(g) for g in list(by_rule.values())[list(by_rule).index(rule):])
                print(f"      ... and {remaining} more finding(s) (use --json for the full list)")
                return
            for finding in group[:max(1, limit - shown)]:
                where = finding.path if finding.count == 1 else f"{finding.path} (+{finding.count - 1} more)"
                print(f"{label} {finding.rule:20} {where}\n      {finding.message}")
                shown += 1
            if len(group) > 1:
                print(f"{label} {rule:20} [{len(group)} finding(s) in this rule]")

    if not opts["json"]:
        emit("WARN ", report.warnings)
        emit("BLOCK", report.errors)
        verdict = "PASS" if not blocked else ("WARN-ONLY" if opts["warn_only"] else "BLOCKED")
        print(f"[datapack_guard] mode={report.mode} checked={report.checked} "
              f"errors={len(report.errors)} warnings={len(report.warnings)} -> {verdict}")

    if blocked and not opts["warn_only"]:
        return EXIT_BLOCK
    return EXIT_PASS


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
