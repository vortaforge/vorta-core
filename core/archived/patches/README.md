# archived/patches/

The archival change set for `vortaforge/core`, as a `git format-patch` mailbox.

> [!IMPORTANT]
> **One patch, applied to a clean pre-retirement `main`.** It is a squash of
> the whole change, not a series, so a reviewer can read the final state
> without watching Turkish text arrive and then leave again.

| File | What it applies |
|---|---|
| `0001-chore-datapacks-retire-the-datapack-programme-arm-th.patch` | Moves every datapack, resource pack, generator, linter and test harness into `archived/` (renames preserved), extracts the datapack Gradle logic out of the root `build.gradle` into `archived/build/*.gradle`, rebuilds `archived/archive.json` as schema v2, and adds the kill switch, the guard, the blocklist, the hooks and the CI job. The live tree ends up English-only. |

Base commit: `42665e9` (`Delete .devcontainer directory`). If `main` has moved
past it, `git am -3` will still apply the patch as long as the touched files
have not changed; a rejected hunk means `main` changed underneath it and the
patch must be regenerated rather than hand-fixed.

## Apply

```bash
git clone https://github.com/vortaforge/core.git
cd core
git checkout -b datapacks-retired

git am archived/patches/*.patch

# If the tree moved underneath the patch, try the three-way merge:
git am -3 archived/patches/*.patch

# A rejected hunk is a signal, not an obstacle:
git am --abort
```

`git am` recreates the commit on your branch (new hash). It never rewrites
`main`.

Files only, with your own commit message:

```bash
git apply --stat  archived/patches/0001-*.patch
git apply --check archived/patches/0001-*.patch
git apply         archived/patches/0001-*.patch
```

## Verify after applying

```bash
python3 scripts/check_archive.py --strict          # 28 entries, 0 errors
python3 scripts/datapacks_disable.py verify        # 0 problems
python3 scripts/origin_watermarks.py --check       # 15 watermarks, 11 datapacks
python3 -m unittest discover -s scripts/tests      # 84 tests
node scripts/tests/site_behavior.test.mjs
```

> [!NOTE]
> The applied tree is byte-identical to the one this patch was generated from:
> `diff -r` is empty. That was checked against a pristine `git archive` of the
> base commit, not against the author's working copy.

## The sibling patch

`vortaforge/.github` gets its own patch, applied **after** this one:
`../patches-gh/0001-feat-blocklist-organisation-wide-datapack-blocklist-.patch`.
It holds the org-wide blocklist mirror, the sync script and the sync workflow.
