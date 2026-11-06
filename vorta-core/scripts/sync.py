#!/usr/bin/env python3
"""Reconcile the committed index with what GitHub actually has right now.

This is the piece that makes the sync a sync rather than a report. It compares
three things:

    index.json    what this repository believes exists   (committed)
    events.log    what has happened over time            (append-only)
    GitHub        what exists right now                  (discovered)

and emits the events that bridge them. Two properties matter:

* **Deletion is detected, not inferred.** A repository that is in the index and
  absent from GitHub is gone. There is no "maybe the token lost access" branch,
  because the discovery call and the comparison run on the same listing - if the
  token could not see the org, discovery would have failed outright rather than
  returning an empty list.

* **The run is idempotent.** Every event is keyed by (type, repo) and the ledger
  is consulted before writing, so running the same reconciliation twice writes
  nothing the second time. That matters because the scheduled workflow and a
  manual dispatch can overlap.

Exit codes:
    0  in sync (or --dry-run: would have changed)
    1  differences found and --check was passed
    2  the reconciliation itself failed

Usage:
    python3 scripts/sync.py --org vortaforge --apply
    python3 scripts/sync.py --org vortaforge --check
"""
from __future__ import annotations

import argparse
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from discover import discover  # noqa: E402
from record_event import append  # noqa: E402

INDEX = Path("index.json")
LEDGER = Path("events.log")

# Fields whose change is worth an event. `pushedAt` is deliberately absent: a push
# is content moving, which GitHub already tells you, and putting it here would make
# every single run produce an event for every active repository.
WATCHED_FIELDS = ("description", "visibility", "archived", "defaultBranch",
                  "topics", "language", "hasIssues")


def load_index(path: Path) -> dict:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        return {"org": None, "repositories": []}


def load_ledger(path: Path) -> list[dict]:
    if not path.is_file():
        return []
    events = []
    for number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if not line.strip():
            continue
        try:
            events.append(json.loads(line))
        except json.JSONDecodeError:
            # A hand-edited or truncated line should not take the whole sync down;
            # it is reported and skipped, because losing history is worse than
            # tolerating one bad line in it.
            sys.stderr.write(f"events.log:{number}: unparseable line, skipped\n")
    return events


def already_recorded(events: list[dict], kind: str, repo: str) -> bool:
    """A lifecycle event is once-per-repository; a `changed` event is not."""
    if kind == "changed":
        return False
    return any(e.get("type") == kind and e.get("repo") == repo for e in events)


def diff_fields(current: dict, previous: dict) -> list[str]:
    return [f for f in WATCHED_FIELDS if current.get(f) != previous.get(f)]


def reconcile(org: str, index: dict, events: list[dict],
              current: list[dict]) -> tuple[list[dict], dict]:
    """Return the events that bridge `index` to `current`, and a summary."""
    previous = {r["name"]: r for r in index.get("repositories", [])}
    now = {r["name"]: r for r in current}

    pending: list[dict] = []
    stamp = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")

    for name in sorted(set(now) - set(previous)):
        if already_recorded(events, "created", name):
            continue
        repo = now[name]
        pending.append({
            "at": repo.get("createdAt") or stamp,
            "type": "created",
            "repo": name,
            "detail": repo.get("description", "")[:120],
            "actor": "vorta-core sync",
        })

    for name in sorted(set(previous) - set(now)):
        if already_recorded(events, "deleted", name):
            continue
        pending.append({
            "at": stamp,
            "type": "deleted",
            "repo": name,
            "detail": "present in index.json, absent from the organization",
            "actor": "vorta-core sync",
        })

    for name in sorted(set(now) & set(previous)):
        changed = diff_fields(now[name], previous[name])
        if not changed:
            continue
        # Archived/unarchived and visibility are their own event types: they are
        # the ones a reader looks for, and burying them in a generic `changed`
        # makes the ledger much less useful.
        if "archived" in changed:
            pending.append({
                "at": stamp,
                "type": "archived" if now[name]["archived"] else "unarchived",
                "repo": name, "actor": "vorta-core sync",
            })
        if "visibility" in changed:
            pending.append({
                "at": stamp, "type": "visibility", "repo": name,
                "detail": f"{previous[name].get('visibility')} -> {now[name].get('visibility')}",
                "actor": "vorta-core sync",
            })
        rest = [f for f in changed if f not in ("archived", "visibility")]
        if rest:
            details = "; ".join(
                f"{f}: {_short(previous[name].get(f))} -> {_short(now[name].get(f))}"
                for f in rest
            )
            pending.append({
                "at": stamp, "type": "changed", "repo": name,
                "detail": details[:400], "actor": "vorta-core sync",
            })

    summary = {
        "org": org,
        "repositories": len(now),
        "created": sorted(set(now) - set(previous)),
        "deleted": sorted(set(previous) - set(now)),
        "changed": sorted(
            n for n in set(now) & set(previous)
            if diff_fields(now[n], previous[n])
        ),
        "events": len(pending),
    }
    return pending, summary


def _short(value) -> str:
    text = json.dumps(value) if not isinstance(value, str) else value
    return text if len(text) <= 60 else text[:57] + "..."


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--org", required=True)
    parser.add_argument("--index", type=Path, default=INDEX)
    parser.add_argument("--ledger", type=Path, default=LEDGER)
    parser.add_argument("--apply", action="store_true",
                        help="write the index and append the events")
    parser.add_argument("--check", action="store_true",
                        help="exit 1 when the index is stale")
    args = parser.parse_args(argv)

    index = load_index(args.index)
    events = load_ledger(args.ledger)

    try:
        current = discover(args.org, include_archived=True)
    except SystemExit as exc:
        sys.stderr.write(f"discovery failed: {exc}\n")
        return 2

    pending, summary = reconcile(args.org, index, events, current)

    if args.check:
        print(json.dumps(summary, indent=2))
        return 1 if (summary["created"] or summary["deleted"] or summary["changed"]) else 0

    if args.apply:
        for event in pending:
            append(args.ledger, event)

        by_name = {r["name"]: r for r in index.get("repositories", [])}
        for repo in current:
            by_name[repo["name"]] = repo
        for name in summary["deleted"]:
            by_name.pop(name, None)

        out = {
            "org": args.org,
            "generatedAt": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
            "count": len(by_name),
            "repositories": [by_name[n] for n in sorted(by_name, key=str.lower)],
        }
        args.index.write_text(json.dumps(out, indent=2) + "\n", encoding="utf-8")

    print(json.dumps(summary, indent=2))
    if not pending:
        print("in sync: nothing to record")
    elif not args.apply:
        print(f"dry run: {len(pending)} event(s) would be recorded "
              f"(pass --apply to write them)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
