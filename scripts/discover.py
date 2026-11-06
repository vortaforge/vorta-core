#!/usr/bin/env python3
"""Discover every repository in the organization, with the facts the index needs.

This is the *full* half of the sync. It asks GitHub for the current state rather
than trusting anything local, because the local view is exactly what has gone
stale - a repository created or deleted while the sync was not running.

Output is JSON on stdout so the caller decides where it goes; nothing is written
to disk here. `--check` compares against a previous run and exits non-zero when
the listing changed, which is what the scheduled workflow uses to decide whether
to commit.

Usage:
    python3 scripts/discover.py --org vortaforge > repos.json
    python3 scripts/discover.py --org vortaforge --baseline index.json

The GitHub CLI is used rather than raw HTTP so pagination, retries and the
token lookup are the CLI's problem rather than this script's.
"""
from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from typing import Any


def gh(*args: str) -> str:
    """Run `gh` and return its stdout, failing loudly.

    Deliberately not swallowing stderr: a 403 from a missing scope is the most
    likely failure here, and its message says which scope, which is more useful
    than "exit status 1".
    """
    result = subprocess.run(["gh", *args], capture_output=True, text=True)
    if result.returncode != 0:
        sys.stderr.write(result.stderr.strip() + "\n")
        raise SystemExit(f"gh {' '.join(args)} failed with exit status {result.returncode}")
    return result.stdout


def discover(org: str, *, include_archived: bool) -> list[dict[str, Any]]:
    """Every repository in `org`, one record each, sorted by name."""
    raw = gh(
        "repo", "list", org,
        "--limit", "1000",
        "--json", ",".join([
            "name", "description", "visibility", "isArchived", "isFork",
            "defaultBranchRef", "pushedAt", "createdAt", "primaryLanguage",
            "repositoryTopics", "stargazerCount", "hasIssuesEnabled",
        ]),
    )
    repos = json.loads(raw)

    out: list[dict[str, Any]] = []
    for repo in repos:
        if repo.get("isArchived") and not include_archived:
            continue
        topics = [t["name"] for t in (repo.get("repositoryTopics") or [])]
        out.append({
            "name": repo["name"],
            "fullName": f"{org}/{repo['name']}",
            "description": repo.get("description") or "",
            "visibility": repo.get("visibility", "unknown"),
            "archived": bool(repo.get("isArchived")),
            "fork": bool(repo.get("isFork")),
            "defaultBranch": (repo.get("defaultBranchRef") or {}).get("name"),
            # Timestamps are normalised to UTC with a Z so a diff between two
            # runs never shows a timezone shuffle as a change.
            "createdAt": _utc(repo.get("createdAt")),
            "pushedAt": _utc(repo.get("pushedAt")),
            "language": (repo.get("primaryLanguage") or {}).get("name"),
            "topics": sorted(topics),
            "stars": repo.get("stargazerCount", 0),
            "hasIssues": bool(repo.get("hasIssuesEnabled", True)),
        })
    return sorted(out, key=lambda r: r["name"].lower())


def _utc(value: str | None) -> str | None:
    if not value:
        return None
    # `gh` already returns ISO-8601 with a Z; anything else is normalised so the
    # comparison is on the instant, not the spelling.
    try:
        parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError:
        return value
    return parsed.astimezone(timezone.utc).isoformat().replace("+00:00", "Z")


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--org", required=True, help="organization to enumerate")
    # Archived repositories are included by default. An archived repository still
    # exists; leaving it out would make the index disagree with the organization
    # and make `archived`/`unarchived` events impossible to detect at all.
    parser.add_argument("--exclude-archived", action="store_true",
                        help="drop archived repositories from the listing")
    parser.add_argument("--baseline", type=str,
                        help="an existing index.json; report what changed since it")
    parser.add_argument("--check", action="store_true",
                        help="exit 1 when the listing differs from --baseline")
    args = parser.parse_args(argv)

    if shutil.which("gh") is None:
        raise SystemExit("gh is required but is not on PATH")

    repos = discover(args.org, include_archived=not args.exclude_archived)

    if args.baseline:
        try:
            with open(args.baseline, encoding="utf-8") as handle:
                baseline = json.load(handle)
        except FileNotFoundError:
            baseline = {}
        previous = {r["name"]: r for r in baseline.get("repositories", [])}
        current = {r["name"]: r for r in repos}

        added = sorted(set(current) - set(previous))
        removed = sorted(set(previous) - set(current))
        changed = sorted(
            name for name in set(current) & set(previous)
            if _diff(current[name], previous[name])
        )

        report = {"added": added, "removed": removed, "changed": changed}
        if args.check:
            print(json.dumps(report, indent=2))
            return 1 if (added or removed or changed) else 0
        sys.stderr.write(json.dumps(report) + "\n")

    print(json.dumps({
        "org": args.org,
        "generatedAt": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        "count": len(repos),
        "repositories": repos,
    }, indent=2, sort_keys=False))
    return 0


def _diff(current: dict[str, Any], previous: dict[str, Any]) -> list[str]:
    """Field names that differ. `pushedAt` alone does not mean "content changed" -
    a push is a push - so the caller reports it separately; here it is included so
    the scheduled run keeps the index current."""
    keys = set(current) | set(previous)
    return sorted(k for k in keys if current.get(k) != previous.get(k))


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
