# Datapack retirement, kill switch and guard - `docs/ARCHIVAL.md`

> [!IMPORTANT]
> **This system is fail-closed.** A malformed blocklist, a missing git ref or an unreadable artefact is never treated as a pass - it is an error. A red gate is proof that the rule works.

> [!NOTE]
> **Patches:** `archived/patches/` (core) and `archived/patches-gh/`
> (`vortaforge/.github`). Validated with 31 registry entries, 90 Python tests
> and Gradle 9.8.2. Installation steps: [`INSTALL.md`](../INSTALL.md).

This document is the operator manual for the 2026-11-05 datapack retirement in
`vortaforge/core`: what was moved, what is now blocked, how to install and use
the guard, and how to reverse the decision deliberately. Why the programme was
retired at all is in [`README.md`](../README.md#why-datapacks-are-not-accepted-any-more).

| Piece | Where | What it does |
|---|---|---|
| Kill switch | `datapacks.disabled.json`, `archived/datapacks.disabled` | `"enabled": false`. Missing/unreadable counts as disabled. |
| Switch CLI | `scripts/repo/datapacks_disable.py` | `status`, `disable`, `enable`, `verify` |
| Guard | `scripts/repo/datapack_guard.py` | blocks new datapacks, revived archived tooling, blocklisted accounts |
| Archive registry | `archived/archive.json` (schema v2), `archived/archive.schema.json` | every retired project, `"disarmed": true` |
| Registry validator | `scripts/repo/check_archive.py` | fail-closed validation incl. disarmed/bijection/no-workflow rules |
| Account blocklist | `blocklist/blocklist.json` | logins, bot/AI rules, public-profile scan policy |
| Hooks | `scripts/git/hooks/pre-commit`, `scripts/git/hooks/pre-push` | run the guard before a commit/push |
| CI | `.github/workflows/quality.yml`, job `datapack-guard` | runs the guard + registry + switch; blocks the quality gate |
| Org-wide mirror | `vortaforge/.github` | `blocklist/`, `scripts/blocklist_sync.py`, `workflows/datapack-blocklist-sync.yml` |
| Extracted Gradle | `archived/build/*.gradle` | the datapack logic that was in the root `build.gradle` |
---

## How do I install it?

### 1. Apply the patch series (recommended)

Every change is a `git format-patch` mailbox under `archived/patches/` (see its
own `README.md` for the order):

```bash
git clone https://github.com/vortaforge/core.git
cd core
git checkout -b datapacks-retired        # never apply straight to main
git am archived/patches/*.patch          # preserves commit messages

# or, to try a single patch first:
git apply --stat  archived/patches/0001-*.patch
git apply --check archived/patches/0001-*.patch
git apply         archived/patches/0001-*.patch
```

`git am` recreates the commits (new hashes); it does not rewrite `main`.

### 2. `vortaforge/.github` (organisation-wide)

```bash
git clone https://github.com/vortaforge/.github.git && cd .github
git checkout -b datapack-blocklist
git am /path/to/core/archived/patches-gh/*.patch
```

`blocklist/blocklist.json` in `.github` is **derived** from `core`'s copy by
`scripts/blocklist_sync.py` and kept current by
`workflows/datapack-blocklist-sync.yml`. Edit `core`'s file and let the sync
run; do not hand-edit the generated one.

### 3. Install the hooks (pre-push blocking)

```bash
git config core.hooksPath scripts/git/hooks
python3 scripts/repo/datapack_guard.py --staged --protect --blocklist   # try it
```

`pre-commit` runs on every commit, `pre-push` on every push. `--no-verify`
bypasses them, which is exactly why the same checks run in CI (job
`datapack-guard`) and a bypass is caught there.

### 4. Verify

```bash
python3 scripts/repo/datapacks_disable.py status
python3 scripts/repo/datapacks_disable.py verify
python3 scripts/repo/check_archive.py --strict
python3 scripts/repo/origin_watermarks.py --check
./gradlew checkDatapackSwitch checkArchive verifyProject
python3 -m unittest discover -s scripts/tests -v
node scripts/tests/site_behavior.test.mjs
```

Expected: switch `enabled=false`, `verify` 0 problems, registry 31 entries /
0 errors, 90 Python tests OK, website test passes.

### 5. Day-to-day use

```bash
python3 scripts/repo/datapacks_disable.py status                       # is it off?
./gradlew printArchiveList                                        # what was archived, and why
python3 scripts/repo/datapack_guard.py --staged --protect --blocklist  # manual check
python3 scripts/repo/datapack_guard.py --audit-refs --blocklist        # branch/tag names
```

### 6. What blocks what

| Surface | Rule | Where |
|---|---|---|
| New pack / new datapack file | blocked | guard, `live-packs-tree` / `new-datapack` |
| Reviving archived tooling (`scripts/dpgen`, `ward`, `mods/datapack-blocker`, ...) | blocked | guard, `retired-tooling` |
| Removing a pack (archiving) | allowed, warning + registry must be updated | guard + `check_archive.py` |
| Blocklisted account opening a PR | blocked | guard `--pr` (needs `datapack-approved` label to override) |
| Blocklisted commit identity pushed | blocked | `pre-push` (`--push`) |
| Force-push to a protected branch | blocked | `pre-push` (`PRE_PUSH_FORCE=1`) |
| Archived entry not `disarmed` | blocked | `check_archive.py` |
| Workflow file under `archived/` | blocked | `check_archive.py` |
| A new datapack-shaped test fixture | allowed | `scripts/tests/fixtures/` and `archived/` are exempt |

### 7. Blocking an account

1. Add the login to `blocklist/blocklist.json` under `blocked[]` with `reason`,
   `added_on`, `added_by`, `scope`, `enforcement`. Exact logins only; use
   `ref_patterns` for branch/tag names. Prefer adding the numeric `user_ids`
   too: `gh api users/<login> --jq .id`.
2. Validate: `python3 scripts/repo/datapack_guard.py --audit-refs --blocklist`.
3. Mirror org-wide: the sync workflow runs on the next `core` push, or locally
   `python3 scripts/blocklist_sync.py --check --write` inside `.github`.
4. For a datapack developer discovered by **profile scan** (bio/company contains
   `datapack`, etc.), the sync job opens an issue with the matched token; the
   account is refused (fail-closed) until the issue is resolved. Public profile
   fields only — never private data.

### 8. Re-enabling (deliberate and expensive)

```bash
python3 scripts/repo/datapacks_disable.py enable \
    --token VORTAFORGE-DATAPACKS-2026-11-05-DISARMED \
    --reason "why, in a sentence"
```

That only flips the switch. Packs stay disarmed in `archived/`. A real restore
means moving each pack back with `git mv`, deleting its registry entry and
`original_path`, re-applying the archived `archived/build/*.gradle` sections by
hand, then running `check_archive.py` and `verifyProject`. Treat it as a new
project proposal with the review the first one never had.

### 9. Troubleshooting

| Symptom | Cause / fix |
|---|---|
| `datapack_guard ... fail-closed` | The guard could not read an input (missing git ref, broken blocklist). This is a failure, not a skip. |
| `check_archive: '...' does not exist` | Registry and tree disagree; restore the file or fix the entry. |
| `checkDatapackSwitch failed` | The switch is not `enabled=false`, or the marker/registry disagree. |
| `pre-push: force-push detected` | Protected branch; add commits instead of rewriting history (`docs/MAINTAINER_GUIDE.md`). |
| CI `Datapack guard` red | The diff adds datapack content, the account is blocklisted, or an archive rule broke; the artifact `datapack-guard-report` names the rule. |
| Source tarball, no `.git` | Diff checks are skipped with a warning; registry and blocklist checks still run. |
