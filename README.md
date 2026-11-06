# vorta-core

Keeps one record of every repository in the organization — what exists, what it
looks like, and what happened to it — and keeps that record honest.

Three things get synced, which is exactly the set that a snapshot alone cannot
cover:

| | |
|---|---|
| **changes** | a repository's description, visibility, default branch, topics, language, archival state |
| **creation** | a repository appeared in the organization |
| **deletion** | a repository was removed from the organization |

The third one is the reason this repository is not just a generated table.
A deleted repository leaves no trace in a current listing, so it can only be known
if it was written down when it was noticed. That is what `events.log` is for.

## What is in here

```
index.json            snapshot: every repository that exists right now
events.log            ledger: one JSON line per event, append-only
scripts/discover.py   ask GitHub what exists
scripts/sync.py       compare index, ledger and GitHub; emit the difference
scripts/mirror.py     copy every repository's default branch into <repo name>/
scripts/record_event.py  append one event
scripts/receive_event.py webhook receiver (HMAC-verified) + dispatch adapter
tests/test_sync.py    the decision logic, tested without touching GitHub
tests/test_mirror.py  the mirror's file-ownership rules, tested on local repos
.github/workflows/    scheduled sweep, event receiver, health check

core/                 mirror of vortaforge/core
docs/                 mirror of vortaforge/docs        (nests to docs/docs/)
.github/              mirror of vortaforge/.github     (workflows nest, do not run)
macroengine-modules/  mirror of vortaforge/macroengine-modules
vorta-core/           mirror of this repository, one sync behind
```

A mirrored tree is a **snapshot**, not a checkout: no `.git`, not editable, and
overwritten on the next run. `.mirror.json` at the top of each records the commit,
the branch and the time it was taken. Edit in the source repository.

`index.json` answers *"what is there?"*. `events.log` answers *"what happened, and
when?"*, and the mirrored trees answer *"what is in them?"*. None replaces another.

`index.json` answers *"what is there?"*. `events.log` answers *"what happened, and
when?"*. Neither replaces the other: the index is small and current, the ledger is
permanent and grows.

## How it stays current

Three paths, deliberately layered so no single failure loses an event:

1. **Scheduled sweep** (`sync.yml`, every six hours). Needs nothing from the
   outside, so it is the guarantee: a missed event becomes a *late* event.
2. **Event push** (`receive.yml` or the webhook receiver). Low latency — a
   deletion lands in the ledger within seconds of the API call, not six hours
   later.
3. **Health check** (`health.yml`, daily). Reconciles read-only and goes red if
   the index has drifted. A sync that has silently stopped looks exactly like a
   quiet organization, and this is the only thing that tells them apart.

Each run is idempotent, so the three paths may overlap freely. Every lifecycle
event is recorded at most once per repository name; `changed` events may repeat,
because the same repository can change many times.

## Guard rail worth knowing about

Discovery and comparison run on the *same* listing, so "absent from GitHub" always
means absent, never "the token could not see it". On top of that, the workflow
refuses to write anything if the repository count drops by more than half in one
run — a token that lost its scope looks exactly like a mass deletion, and the
second is much rarer than the first.

## Running it locally

```bash
gh auth login                       # needs repo + read:org
python3 tests/test_sync.py          # 13 tests, no network
python3 tests/test_mirror.py        # 5 tests, no network
python3 scripts/discover.py --org vortaforge        # just look
python3 scripts/sync.py --org vortaforge            # dry run
python3 scripts/sync.py --org vortaforge --apply    # write index.json + events.log
python3 scripts/sync.py --org vortaforge --check    # exit 1 on drift

# The mirror needs git credentials, because it clones rather than calling the API:
gh auth setup-git
python3 scripts/mirror.py --org vortaforge           # dry run: what is stale
python3 scripts/mirror.py --org vortaforge --apply   # write the trees
```

The webhook receiver, for a small always-on host:

```bash
WEBHOOK_SECRET=... python3 scripts/receive_event.py --secret "$WEBHOOK_SECRET" --port 8080
```

Point an organization webhook at `https://host:8080/` with content type
`application/json`, a secret, and the `repository` and `push` events. The secret is
not optional on a public endpoint: without it any POST can append to the ledger.
Signatures are checked with `hmac.compare_digest`, and a bad signature gets a bare
`401` with no explanation.

## Verified against the live organization

Not just tested locally:

- **Creation** — a repository created through the API was recorded by the
  `repository_dispatch` path within the minute, then picked up by the next sweep.
- **Deletion** — a repository that vanished from the organization was recorded as
  `deleted` and dropped from the index, by the scheduled run alone
  (`sync: deleted vorta-core-synctest`). This is the case the whole ledger design
  exists for.
- **Change** — a `language: null -> Python` transition became a `changed` event.

Two real bugs were found and fixed by running it rather than reasoning about it:
`persist-credentials: false` silently broke `git push`, and two runs dispatched in
the same second could both commit and one would be rejected — now it rebases and
retries.

## Setup checklist

- [ ] Secret `ORG_READ_TOKEN` — reads the org's repository list (`repo` +
      `read:org`). Write access is not required; the commit uses the workflow's own
      `GITHUB_TOKEN`.
- [ ] Optional variable `SYNC_ORG`, if the organization is not `vortaforge`.
- [ ] The workflows must be on `main` before any dispatch is sent:
      `repository_dispatch` only triggers a workflow file that exists on the
      default branch, so a dispatch sent earlier silently does nothing.
- [ ] Workflow permissions must allow write access (Settings → Actions → General),
      because `sync.yml` commits.

## Event schema

One JSON object per line, never rewritten:

```json
{"at":"2026-11-06T17:37:55Z","type":"archived","repo":"example","actor":"vorta-core sync"}
{"at":"2026-11-06T17:42:30Z","type":"deleted","repo":"gone","detail":"present in index.json, absent from the organization","actor":"vorta-core sync"}
```

`type` is a closed vocabulary — `created`, `deleted`, `changed`, `archived`,
`unarchived`, `renamed`, `visibility` — because a free-text field stops being
aggregatable within a month. `at` is always UTC, and a creation uses the
repository's own creation instant rather than the time the sweep noticed it.

## Limits

- A deletion can only be recorded if it is *seen*. If a repository is created and
  deleted between two sweeps and the webhook missed it, it never enters the ledger.
  The index will still be correct, because it only ever describes what exists.
- Renames arrive as a `deleted` + `created` pair unless the webhook path is live;
  the scheduled sweep has no rename signal to work from.
- Archived repositories are kept in the index (`include_archived`), because an
  archived repository still exists and silently dropping it would be a lie.

## License

See `LICENSE`.
