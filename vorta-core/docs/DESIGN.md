# Design notes

Why this is shaped the way it is. The shape is not arbitrary — each choice below
exists because the obvious alternative loses information.

## Snapshot plus ledger, not one of them

The tempting design is a single `repos.json` regenerated on every run. It is
simple, it is always current, and it cannot answer the one question that matters
when something disappears: *was it deleted, or did we never see it?*

A snapshot of the present has no past. A repository deleted last Tuesday is simply
absent from today's listing, indistinguishable from a repository that never
existed. If the record only ever holds the present, deletion is not a fact that
can be stored — it can only be inferred from a diff of two snapshots, and only if
you happened to keep the older one.

So there are two files:

- `index.json` — current state, small, safe to regenerate from scratch at any
  time. Losing it costs one API call.
- `events.log` — append-only, never rewritten. Losing it costs history.

They are written together but they are not redundant. The index is the state; the
ledger is the transitions. The transition `deleted` only exists in the ledger.

## Why deletion detection is trustworthy here

The dangerous version of this system records "deleted" whenever a repository is
missing from a listing. That is wrong whenever the listing is wrong — an expired
token, a scope that silently dropped, a rate limit returning a short page. Each of
those would be recorded as a mass deletion, and the ledger is append-only, so the
false entries would be permanent.

Three things prevent that:

1. **Same-listing comparison.** Discovery and reconciliation are one call. There is
   no cached listing on one side and a fresh one on the other, so "absent" is a
   statement about a single consistent view.
2. **Failure is loud.** `discover()` raises on a non-zero exit rather than
   returning an empty list, so a broken call cannot look like an empty
   organization.
3. **The half-drop guard.** Even with the above, the workflow refuses to write
   when the count falls by more than half in one run. A genuine halving of the
   organization is possible; a token losing its scope is far more likely, and the
   cost of being wrong is asymmetric — a skipped run fixes itself in six hours, a
   wrong ledger entry never does.

## Once-only lifecycle events

`created` and `deleted` are recorded at most once per repository name; `changed`
may repeat.

This comes from what the events mean. "This name was created" is a fact about a
name, so recording it twice is noise. "This repository changed" is a fact about an
instant, so recording it every time it happens is correct.

Consequence worth stating: **delete-then-recreate does not produce a second
`created` event.** The ledger keeps the first creation instant for that name, and
the recreation appears as the `deleted` that preceded it followed by… nothing new.
That is a real limitation of keying by name, and it is accepted rather than hidden:
the alternative is keying by repository id, which the index does not carry today.
If that becomes important, the fix is to add `id` to each record and key the
once-only check on `(type, id)` instead of `(type, name)`.

## Why `pushedAt` is not a watched field

A push is content moving, and GitHub already reports it in detail. Watching
`pushedAt` would make every active repository produce a `changed` event on every
run of every path — three sources of noise where the ledger is supposed to hold
signal. Pushes from the webhook path are recorded as `changed` with a commit count,
because there the event *is* the push; the sweep never infers one.

## Fast path versus guarantee

`repository_dispatch` gives low latency and has one sharp edge: it only triggers a
workflow file that exists **on the default branch**. Send one before `receive.yml`
is merged into `main` and nothing happens, with no error anywhere — the dispatch
returns 204 and the run never starts.

That edge is why the schedule exists and is not optional. It is the only trigger
that cannot be defeated by a missing file, a stale branch, or a token that was
rotated. The fast path is an optimization on top of the guarantee, never a
replacement for it.

## Why the webhook receiver is a separate script

`scripts/receive_event.py` runs two ways: as a small HTTP service (a real webhook
endpoint, HMAC-verified) and as a one-shot adapter that turns a
`repository_dispatch` payload into a ledger line. Both call the same
`record_event.append`.

Two rules it follows:

- **It never calls GitHub.** Recording must not depend on a second network call
  succeeding. If the API is unreachable, the event is still in the ledger and the
  next sweep fixes the index.
- **It rejects non-slugs.** The ledger is append-only, so a malformed repository
  name is a permanent bad line. The name is validated against `^[A-Za-z0-9._-]+$`
  before anything is written.

## What is deliberately not built

- **No pruning of `events.log`.** A ledger you can edit is a ledger you cannot
  cite. It grows by one line per event, which is a rounding error next to a
  repository.
- **No storing commit contents.** Pointers, always: repository, timestamp, event,
  one line of context. Copying code into this repository would make it a second
  source of truth for things that already have one.
- **No auto-fix in `health.yml`.** It reports drift and goes red; the scheduled
  job repairs it. A checker that also writes cannot tell you whether the writer
  works.

## The mirror: recording content, not just existence

`index.json` answers *what repositories are there*. It does not answer *what is in
them*, and for a while nothing did — the sync was a register of names with no
contents attached.

So each repository's default branch is now mirrored into a directory named after
it:

```
core/                     vortaforge/core, as of the last sync
docs/                     vortaforge/docs
.github/                  vortaforge/.github
```

### Why a directory and not a submodule

Submodules keep a real relationship: the recorded commit is pinned, `git
submodule update` fetches it, history stays in the source repository. They also
require a network round trip and a second command to read anything, and they
break every tool that walks the tree without initialising them first. A reader
looking at this repository in a browser sees an empty directory.

The mirror is a plain snapshot instead, so it reads as files. The cost is that it
is always as stale as the last sync — stated plainly in each tree's
`.mirror.json`, which records the commit, the branch and the time.

### Why the name is at the root, and the collisions that follow

A repository named `docs` mirrors to `docs/`, which is also where this
repository's own design notes live. Two things make that safe:

1. The source trees nest. `vortaforge/docs` keeps its pages in `docs/`, so they
   land in `docs/docs/`; `vortaforge/.github` keeps its workflows in
   `.github/workflows/`, so they land in `.github/.github/workflows/`. No file
   collides.
2. A nested workflow is inert. GitHub reads `.github/workflows/` at a repository
   root and nowhere else, so nothing in a mirrored tree can run.

Both are properties of the current repositories, not guarantees, so the mirror
checks. Before writing, it compares the incoming file list against the
destination and refuses on the first real file collision. A directory being *held*
in common is ordinary; a file being overwritten is not.

### What a mirror may delete, and what it may not

The destination directory is shared with this repository's own files, so "clear
the directory and re-copy" is wrong — it deleted `docs/OPERATIONS.md` the first
time it ran. Instead each tree carries a manifest listing exactly the paths the
mirror wrote, and a re-sync removes exactly those. Files it did not write are
invisible to it.

That in turn is why the manifest is built from what was *copied* rather than from
a listing of the destination: a manifest built by walking `docs/` would claim this
repository's own notes and license their deletion on the next run.

### Self-mirroring

`vorta-core` is one of the repositories being mirrored, so `vorta-core/` holds a
copy of this repository as of the previous sync. It is taken from GitHub, not from
the working directory, which is why it cannot recurse: the clone predates the
directory it would be written into. The `vorta-core/` directory inside it is
excluded by name as a second guarantee — without it, each run would nest one level
deeper.
