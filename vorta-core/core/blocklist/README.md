# blocklist/

> [!WARNING]
> **This file is public and will be read by the person who is blocked.** Every entry must state a *policy decision*, not a personal accusation. An entry without a reason is rejected by the tests.

Account-level blocklist for the retired datapack programme.

- `blocklist.json` — the list itself (schema: the file's own `$comment`s and
  the table below). Read by `scripts/repo/datapack_guard.py` and mirrored
  organisation-wide by `vortaforge/.github`.
- Enforcement points: `scripts/git/hooks/pre-commit`, `scripts/git/hooks/pre-push`, the
  `datapack-guard` job in `.github/workflows/quality.yml`, and the
  `Datapack blocklist sync` workflow in `vortaforge/.github`.

## The override label

`datapack-approved` is the only override, and it is deliberately narrow:

- It clears entries whose `enforcement` is `review`. It becomes a warning, not
  a pass, so the override is still visible in the guard report.
- It does **not** clear `enforcement: block` entries, and it does not touch
  content rules: a new datapack under `packs/` is refused with or without the
  label.
- It does not disable the archive-registry or kill-switch checks.

## What an entry means

| Field | Meaning |
|---|---|
| `id` | Stable id, `[a-z0-9-]+`. Referenced by copies in `.github/blocklist/`. |
| `reason` | Required. A block without a written reason is a bug; `check_archive`-style review will reject it. |
| `enforcement` | `block` (refuse outright) or `review` (refuse, but a maintainer may clear it with the `datapack-approved` label). Only these two are accepted; anything else fails the blocklist load. |
| `scope` | Where it applies: `pull_request`, `push`, `org_membership`. Omit it to apply everywhere. An unknown or empty value fails the blocklist load rather than being silently ignored. |
| `logins` | Exact GitHub logins, lower-case. **No wildcards** in this file — a pattern like `misode*` would also match unrelated accounts. |
| `user_ids` | Optional immutable numeric ids; survive a login rename. Get them with `gh api users/<login> --jq .id`. Enforced by `--login-id`, which `quality.yml` feeds from the pull request payload; the login check on its own cannot see a rename, so an entry with ids is only rename-proof when the caller supplies the id. |
| `ref_patterns` | Branch/tag *name* globs (e.g. `*/misode*`) used by `--audit-refs` / the sync job. |
| `match_bot_suffix` | Match any login ending in `[bot]`, `-bot`, `_bot`, `.bot`. |
| `match_ai_accounts` | Match AI-agent-looking logins (see the entry's `notes`). |
| `profile_scan` | Entry is a placeholder for a login discovered through public-profile scanning; a human confirms or exempts each hit. |

Accounts in `managed.accounts` / `managed.owners` are **never** matched by the
broad rules. Put your own bots there instead of in `blocked`.

## Blocking a developer

```bash
# 1. Find the immutable id (survives renames)
gh api users/<login> --jq '.id'

# 2. Add an entry and validate it
$EDITOR blocklist/blocklist.json
python3 scripts/repo/datapack_guard.py --audit-refs --blocklist

# 3. Mirror it org-wide (from the vortaforge/.github repository)
python3 scripts/blocklist_sync.py --check
```

Do not add someone for a technical disagreement. Write down in `reason` what
happened and which policy decision it maps to; this file is public and will be
read by the blocked person.

## Profile scan (datapack developer detection)

`policy.profile_scan` is performed only by `vortaforge/.github`'s
`.github/scripts/blocklist_sync.py`, with a read-only token, against **public**
profile fields (`bio`, `company`, `name`, `blog`) and only for accounts that
already interacted with the organisation (PR author, issue author, org
invitation). It never reads private data, never scans GitHub globally, and a
hit does not auto-block anyone: it opens an issue in `vortaforge/.github` with
the matched token. Until that issue is resolved the account's pull requests are
refused (fail-closed).

## Removing an entry

Remove it from `blocked`, run `--audit-refs --blocklist` and `--check-archive`,
and say why in the commit message. Exemptions are permanent record: prefer
moving a login into `managed.accounts` over deleting the entry if the person
should keep contributing to mods.
