# packs/ — retired

> [!NOTE]
> **This directory is empty on purpose.** The only files allowed here are this README and `.gitkeep`. Adding a new pack is refused by the guard (`live-packs-tree`).

This directory is intentionally empty.

**Datapacks were retired on 2026-11-05.** Every pack, datapack generator,
linter and test harness was archived and disarmed under `../archived/`
(registry: `../archived/archive.json`, schema v2, every entry
`"disarmed": true`), and `datapacks.disabled.json` (`"enabled": false`) is the
kill switch that keeps it that way.

Why: no type safety, no security model, no debugging, no warnings, a low review
score — bad enough that it would have been better not to ship it at all. The
maintainer also hit real problems as a plain player using a datapack with no
client mod installed, and the same class of problems kept coming back in pull
requests.

`scripts/repo/datapack_guard.py` refuses new datapack content here in
`pre-commit`, `pre-push` and CI. This README is the only file this directory
is allowed to contain.

- Policy and install manual: [`../docs/ARCHIVAL.md`](../docs/ARCHIVAL.md)
- What is archived, and why: [`../archived/README.md`](../archived/README.md)
