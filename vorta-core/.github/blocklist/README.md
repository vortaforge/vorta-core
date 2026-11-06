# blocklist/ (organisation-wide)

**Generated. Do not edit by hand.** The source of truth is
`vortaforge/core`'s `blocklist/blocklist.json`; this copy is written by
`scripts/blocklist_sync.py` and committed by
`.github/workflows/datapack-blocklist-sync.yml`.

| File | Meaning |
|---|---|
| `blocklist.json` | The mirror, normalised (sorted entries, `generated_on`, `generated_from`). |
| `../generated/blocklist.json` | The same data for tooling that should not read the editable path. |
| `../generated/profile-scan.json` | Output of the last public-profile scan (accounts, verdicts, matched tokens). |

## How enforcement works

**Distribution and enforcement are different things.** This repository
distributes the policy; it does not enforce it. Concretely:

1. `vortaforge/core`'s guard (`scripts/repo/datapack_guard.py`) is the only
   component that enforces anything. It refuses pull requests from blocked
   logins, refuses blocked commit identities on push, and checks numeric user
   ids. The `datapack-approved` label clears `enforcement: review` entries only.
2. This repository's sync workflow keeps the mirrored list current and opens an
   issue when the profile scan matches an account. It does not touch any other
   repository, and no other repository currently runs an equivalent guard.
3. An account is only blocked by a human editing `vortaforge/core`'s blocklist.
   The profile scan cannot block anyone by itself; it reports.

### What "organisation-wide" does and does not mean here

The list is organisation-*wide* in scope, not in reach:

- One canonical list, mirrored to this repository so it is visible and
  reviewable where organisation policy usually lives.
- Enforcement reach is **`vortaforge/core` only**. A blocked account can still
  open a pull request on another repository in the organisation; nothing
  checks it.
- GitHub's organisation default community files do not propagate workflows, so
  this repository cannot make other repositories run the guard.

Making the reach match the scope would mean either enabling organisation-wide
rulesets (a GitHub setting, not a file in this repository) or having every
repository run the guard. Until one of those exists, this README does not
claim more than the first point.

## The profile scan

- Runs against accounts that already interacted with the organisation (recent
  PR/issue authors). Never a global search.
- Reads **public** profile fields only: `bio`, `company`, `name`, `blog`.
- Matches the tokens in `policy.profile_tokens` (`datapack`, `mcfunction`,
  `pack.mcmeta`, ...), unless the profile carries a
  `policy.profile_exempt_tokens` phrase.
- Writes `generated/profile-scan.json`; never prints a token or credential.

## Changing the list

```bash
# in a vortaforge/core checkout
$EDITOR blocklist/blocklist.json
python3 scripts/datapack_guard.py --audit-refs --blocklist

# in this repository, to preview/refresh the mirror locally
python3 scripts/blocklist_sync.py --check --core ../core   # exit 1 = drift
python3 scripts/blocklist_sync.py --write --core ../core
```

Every entry needs a `reason`, an `added_on` and an `added_by`. Exact logins
only - no wildcards; use `ref_patterns` for branch/tag names and `user_ids` for
rename-proof numeric ids (`gh api users/<login> --jq .id`). This file is public
and will be read by the blocked person, so the reason must be a policy decision,
not an insult.
