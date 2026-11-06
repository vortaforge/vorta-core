# patches/

The organisation-wide blocklist change set for `vortaforge/.github`, as a
`git format-patch` mailbox.

> [!IMPORTANT]
> **Apply the `vortaforge/core` patch first.** This patch mirrors core's
> `blocklist/blocklist.json`; applied to a tree whose core has not been
> updated, the mirror will disagree with the source and the sync check fails.

| File | What it applies |
|---|---|
| `0001-feat-blocklist-organisation-wide-datapack-blocklist-.patch` | Adds `blocklist/` (the generated mirror), `generated/blocklist.json`, `scripts/blocklist_sync.py` and `.github/workflows/datapack-blocklist-sync.yml`. |

Base commit: `bc8fca4`.

## Apply

```bash
git clone https://github.com/vortaforge/.github.git
cd .github
git checkout -b datapack-blocklist
git am /path/to/core/archived/patches-gh/*.patch
```

## Verify after applying

```bash
python3 scripts/blocklist_sync.py --check --core ../core    # exit 0 = in step
```

> [!NOTE]
> `blocklist/blocklist.json` is generated. Run `--write --core ../core` instead
> of editing it; the next sync workflow run will overwrite a hand edit and the
> drift check will fail first.
