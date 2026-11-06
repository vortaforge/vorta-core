# Installation

> [!IMPORTANT]
> **This is an installation guide, not a rollback guide.** The patches change
> `main`: the datapack programme is switched off, `packs/` is emptied and 3546
> files move into `archived/`. Read [`docs/ARCHIVAL.md`](docs/ARCHIVAL.md) §6
> before you plan any reversal.

This page covers the patches that implement the 2026-11-05 datapack retirement
in `vortaforge/core`. The full system description, in one language, is
[`docs/ARCHIVAL.md`](docs/ARCHIVAL.md). The policy itself is
[`archived/README.md`](archived/README.md).

| Repository | Patch |
|---|---|
| `vortaforge/core` | `archived/patches/0001-chore-datapacks-retire-the-datapack-programme-arm-th.patch` |
| `vortaforge/.github` | `archived/patches-gh/0001-feat-blocklist-organisation-wide-datapack-blocklist-.patch` |

Order matters: apply `core` first, then `vortaforge/.github`.

## 1. `vortaforge/core`

```bash
git clone https://github.com/vortaforge/core.git
cd core
git checkout -b datapacks-retired
git am archived/patches/*.patch        # applied in filename order
```

`git am` recreates the commits, so their hashes change. It never rewrites
`main`. If the series fails to apply, run `git am --abort` and start again
rather than editing hunks by hand.

Files only (your own commit message):

```bash
git apply --stat  archived/patches/0001-*.patch
git apply --check archived/patches/0001-*.patch
git apply         archived/patches/0001-*.patch
```

## 2. `vortaforge/.github` (after `core`)

```bash
git clone https://github.com/vortaforge/.github.git
cd .github
git checkout -b datapack-blocklist
git am /path/to/core/archived/patches-gh/*.patch
```

The mirror in `.github/blocklist/blocklist.json` is **generated** from
`core/blocklist/blocklist.json` by `scripts/blocklist_sync.py`. Edit the source
in `core`; never hand-edit the mirror.

## 3. Install the hooks (pre-push blocking)

```bash
cd core
git config core.hooksPath scripts/git/hooks
```

## 4. Verify

```bash
python3 scripts/repo/check_archive.py --strict          # 31 entries, 0 errors
python3 scripts/repo/datapacks_disable.py verify        # 0 problems
python3 scripts/repo/origin_watermarks.py --check       # 15 watermarks, 11 datapacks
python3 -m unittest discover -s scripts/tests      # 90 tests
node scripts/tests/site_behavior.test.mjs
./gradlew checkDatapackSwitch checkArchive verifyProject
```

Expected end state:

- `packs/` contains only `README.md` and `.gitkeep`;
- `archived/packs/` holds 12 packs, `archived/tools/` holds 6 tools and
  `archived/build/` holds the 6 Gradle sections extracted from the root
  `build.gradle`;
- `datapacks.disabled.json` reads `"enabled": false`.

## 5. Day-to-day use

```bash
python3 scripts/repo/datapacks_disable.py status                       # is it off?
./gradlew printArchiveList                                        # what was archived, and why
python3 scripts/repo/datapack_guard.py --staged --protect --blocklist  # manual check
```

## 6. Re-enabling (deliberate)

```bash
python3 scripts/repo/datapacks_disable.py enable \
    --token VORTAFORGE-DATAPACKS-2026-11-05-DISARMED \
    --reason "one sentence explaining why this is being re-enabled"
```

This only turns the switch. The packs stay `disarmed` under `archived/`. The
complete reversal procedure is in [`docs/ARCHIVAL.md`](docs/ARCHIVAL.md).

## Notes

> [!NOTE]
> The applied tree and the patch are byte-identical: `diff -r` is empty after
> applying. If it is not, the patch is not the artefact you think it is.

- The patch does **not** rewrite the `_vc_origin.mcfunction` watermarks of the
  archived packs. Those are provenance records that name the historical
  `packs/<name>` source path, and `scripts/repo/origin_watermarks.py` understands the
  moved tree.
- **Verified:** `check_archive --strict`, `datapacks_disable verify`,
  `origin_watermarks --check`, 90 Python tests, the Node site test, Groovy
  parsing, and Gradle 9.8.2 (JDK 21) with `guardArchives checkDatapackSwitch
  checkArchive verifyMod testRepository writeProjectInventory` plus
  `printArchiveList`.
- **Not verified:** a full `./gradlew ci` against a real `mods/` tree (Fabric
  Loom plus network), `testGuiGenerator` (needs pytest and an installed
  guigenmc), Ward (no Minecraft server was started), and the `.github`
  workflows themselves (only their YAML was validated).
