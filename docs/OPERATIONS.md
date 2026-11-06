# Operations

What to do when it is red, and what to check before it goes red.

## First-time setup

1. **Secret** — Settings → Secrets and variables → Actions → New secret:
   `ORG_READ_TOKEN`.

   A fine-grained token needs, on the organization: *Metadata: read* (which is
   what repository listing needs) and *Organization members: read*. A classic
   token needs `repo` (or `public_repo` if every repository is public) and
   `read:org`.

   It does **not** need write access. The commit is made with the workflow's own
   `GITHUB_TOKEN`.

2. **Write permission for workflows** — Settings → Actions → General → Workflow
   permissions → *Read and write*. Without it `sync.yml` fails at `git push` with
   a permissions error that does not mention permissions.

3. **Optional variable** — Settings → Secrets and variables → Actions → Variables:
   `SYNC_ORG`, if the organization is not `vortaforge`.

4. **Merge first, dispatch later.** `repository_dispatch` only triggers a workflow
   file that exists on the default branch. Send a dispatch before `receive.yml` is
   on `main` and it returns 204 and does nothing, with no failure to notice.

## Daily shape

| Workflow | When | Does |
|---|---|---|
| `sync.yml` | every 6 h at :17, plus dispatch | reconciles and commits |
| `receive.yml` | on dispatch | records one event, commits |
| `health.yml` | daily at 05:43 | read-only drift check, goes red |

The cron minutes are deliberately odd (`:17`, `:43`) — GitHub delays scheduled
runs under load, and picking a minute nobody else picks makes the delay shorter.

## Verified behaviour

Everything below was run against the live organization, not only tested locally.

- **Creation** — a repository created through the API was recorded by
  `repository_dispatch` in the same minute (`event: created sync-demo-repo`), and
  appeared in `index.json` on the next sweep.
- **Deletion** — a repository that disappeared from the organization was recorded
  as `deleted` with the detail *"present in index.json, absent from the
  organization"*, and dropped from the index in the same commit
  (`sync: deleted vorta-core-synctest`). Nobody asked for it; the scheduled run
  found it.
- **Change** — a `language: null -> Python` transition was recorded as a `changed`
  event on the run that first saw the repository.

## When `health.yml` is red

It means `index.json` does not match the organization. Read the run summary: it
prints the full reconciliation JSON, which lists exactly what differs.

**Almost always the right response is to do nothing.** The next `sync.yml` sweep
repairs it. Red here after a recent change is expected if the change happened
between the last sweep and this check.

Escalate when it stays red across two or more checks — that means `sync.yml` is
not doing its job:

1. Is `sync.yml` failing? Check its run history. If it is failing, the reason is
   in its log — usually the token.
2. Is `sync.yml` not running at all? A workflow with a cron trigger is **disabled
   automatically after 60 days with no repository activity**. That is the single
   most common cause of a silent stop, and it is invisible: the schedule simply
   stops, no failure is recorded. Re-enable it from the Actions tab.
3. Is the drift a real deletion? Then `sync.yml` will record it on its next run,
   and the red run is the correct report of a change that has not been committed
   yet.

## When `sync.yml` refuses to run

The message names which guard fired.

**"The token sees no repositories"** — `ORG_READ_TOKEN` is empty, expired, or
scoped to the wrong organization.

**"Repository count fell from N to M"** — the half-drop guard. Either a huge real
deletion happened, or the token lost visibility of private repositories. This is
worth taking seriously, because the two cases look identical from inside the run
and one of them would write false `deleted` entries that can never be removed.

To confirm which:

```bash
GH_TOKEN=... python3 scripts/discover.py --org vortaforge | python3 -c \
  'import json,sys; d=json.load(sys.stdin); print(d["count"]); [print(" ", r["visibility"], r["name"]) for r in d["repositories"]]'
```

If the private repositories are missing from that listing, it is the token. If
they are listed and genuinely gone, the deletion is real — commit the index by
hand or re-run after the guard's threshold no longer applies.

## `git push` rejected

Two runs writing at once. The workflow handles this by rebasing and retrying up to
three times, because both pushed files are rebase-friendly by construction:
`events.log` is append-only one-line JSON and `index.json` is regenerated from
GitHub. If it still fails after three attempts, it is a manual push conflicting
with a run — pull, then re-run.

## A bad ledger line

`events.log` is append-only on principle, and nothing in the tooling rewrites it.
A line that is wrong is therefore a deliberate decision rather than a routine fix:

- **Malformed JSON** — the sync skips it with a warning and keeps going, because
  one bad line is better than a stopped sync. Fix it with a normal commit.
- **Wrong event** — the honest correction is a follow-up event, not an edit. If a
  repository was recorded as deleted and it was not, record a `created`. If it
  truly must be removed, that is a one-line commit and the history of *that* is in
  `git log` — which is where a correction belongs.

## Rotating the token

1. Create the new token, add it as `ORG_READ_TOKEN`.
2. Run `health.yml` manually. It uses the read path end to end and is safe to run
   any number of times.
3. Revoke the old token.

`sync.yml` will pick up the new secret on its next run; no code change is needed.

## Known limitation: the token needs `delete_repo` to tidy up

Detecting a deletion needs only read access — that part is proven. *Performing*
one by hand, e.g. removing a throwaway test repository, needs the token to carry
the `delete_repo` scope, which is a separate grant:

```bash
gh auth refresh -h github.com -s delete_repo
```

Without it the API returns `403 Must have admin rights to Repository`, which reads
like a permissions problem on the repository and is really a missing scope on the
token. The sync is unaffected either way.

## Checking the sync locally before trusting it

```bash
python3 tests/test_sync.py            # the decision logic, 12 tests, no network
python3 scripts/sync.py --org vortaforge        # dry run: what would change
```

The dry run performs real discovery and real comparison; only the write is
skipped. It is the same code path the workflow uses, so a clean dry run is a
meaningful signal rather than a smoke test.
