# archived/patches-gh/

The `vortaforge/.github` patch, kept here too so one checkout carries the whole
change set. The authoritative copy lives in that repository's `patches/`.

Apply order: **core first, then this.** The `.github` change mirrors core's
`blocklist/blocklist.json`.

```bash
git clone https://github.com/vortaforge/.github.git && cd .github
git checkout -b datapack-blocklist
git am /path/to/core/archived/patches-gh/*.patch
```
