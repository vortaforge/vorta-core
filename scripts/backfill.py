#!/usr/bin/env python3
"""Seed the ledger with creation events from the index's own timestamps.

A sync that starts from an empty ledger has no history: the first run sees five
repositories that "already existed" and records nothing, so every one of them
looks like it appeared out of nowhere. GitHub already knows when each repository
was created — `createdAt` is in the index — so the honest starting point is to
write those down rather than pretend the past did not happen.

This is a one-time bootstrap, run once against an empty or partial ledger. It is
idempotent like everything else: a repository that already has a `created` event
is skipped, so running it again is harmless.

Usage:
    python3 scripts/backfill.py --org vortaforge
    python3 scripts/backfill.py --org vortaforge --apply
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from record_event import append  # noqa: E402
from sync import already_recorded, load_ledger  # noqa: E402

INDEX = Path("index.json")
LEDGER = Path("events.log")


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--org", required=True)
    parser.add_argument("--index", type=Path, default=INDEX)
    parser.add_argument("--ledger", type=Path, default=LEDGER)
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args(argv)

    index = json.loads(args.index.read_text(encoding="utf-8"))
    events = load_ledger(args.ledger)

    pending = []
    for repo in index.get("repositories", []):
        name = repo["name"]
        if already_recorded(events, "created", name):
            continue
        # The repository's own creation instant, not "now". A backfilled event
        # that claims the repository was created at the moment of the backfill is
        # worse than no event: it is wrong and it looks authoritative.
        pending.append({
            "at": repo.get("createdAt"),
            "type": "created",
            "repo": name,
            "detail": "backfilled from GitHub createdAt",
            "actor": "backfill",
        })

    if not pending:
        print("ledger already has a creation event for every indexed repository")
        return 0

    if args.apply:
        for event in sorted(pending, key=lambda e: e["at"] or ""):
            append(args.ledger, event)

    print(json.dumps({"would_record": len(pending), "apply": bool(args.apply),
                      "repositories": [e["repo"] for e in pending]}, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
