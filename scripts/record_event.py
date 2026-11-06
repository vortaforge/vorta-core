#!/usr/bin/env python3
"""Record one repository event in the ledger.

The index (`index.json`) is a snapshot: it says what exists now. This ledger says
*what happened*, one line per event, appended and never rewritten. Both are
needed and they answer different questions:

    index.json   "which repositories exist, and what do they look like?"
    events.log   "when was this one created, what changed, when was it deleted?"

A snapshot alone cannot answer the second question, because a repository that
was deleted leaves no trace in it. That is the whole reason a deletion has to be
recorded at the moment it is noticed rather than reconstructed later.

The file is newline-delimited JSON so a human can `tail` it and a machine can
stream it without loading the whole thing.

Usage:
    python3 scripts/record_event.py --type created --repo core
    python3 scripts/record_event.py --type deleted --repo old-thing \
        --detail "removed from org 2026-11-06"
    python3 scripts/record_event.py --type changed --repo core --detail "push to main"
"""
from __future__ import annotations

import argparse
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

LEDGER = Path("events.log")

# The vocabulary. Kept small and closed on purpose: a free-text `type` makes the
# ledger unaggregatable within a month.
EVENT_TYPES = ("created", "deleted", "changed", "archived", "unarchived",
               "renamed", "visibility")


def append(path: Path, event: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as handle:
        handle.write(json.dumps(event, sort_keys=True) + "\n")


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--type", required=True, choices=EVENT_TYPES)
    parser.add_argument("--repo", required=True, help="repository name or owner/name")
    parser.add_argument("--detail", default="", help="one line of context")
    parser.add_argument("--actor", default="", help="who or what noticed it")
    parser.add_argument("--ledger", type=Path, default=LEDGER)
    parser.add_argument("--at", default=None,
                        help="ISO-8601 timestamp; defaults to now (UTC)")
    args = parser.parse_args(argv)

    at = args.at or datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
    event = {
        "at": at,
        "type": args.type,
        "repo": args.repo,
    }
    if args.detail:
        event["detail"] = args.detail
    if args.actor:
        event["actor"] = args.actor

    append(args.ledger, event)
    print(json.dumps(event, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
