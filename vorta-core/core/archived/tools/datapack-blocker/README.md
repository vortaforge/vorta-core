# Datapack Blocker

A Fabric mod (1.21.1) that locks a world's `datapacks/` folder instead of leaving it open to arbitrary drop-in changes.

## What it does

1. **First run on a world** - every pack in `datapacks/` (a directory or a `.zip`) is recorded in `<world>/datapack_blocker/allowlist.txt` with a SHA-256 fingerprint of its contents. Nothing is blocked yet (trust on first use).
2. **Every later start** - a pack is accepted only if its name is on the allowlist **and** its fingerprint still matches. A new pack, or an approved pack whose contents changed, is moved to `<world>/datapack_blocker/quarantine/<timestamp>/`. Nothing is deleted.
3. Accepted packs have their write bits removed recursively (owner/group/other), so they cannot be edited in place without `unlock`.

### When quarantining really prevents loading

The server reads `datapacks/` *before* `SERVER_STARTING` fires, so version 1.0.0 (which moved packs there) could not stop a pack from loading in that run. From 1.1.0:

- **Dedicated server:** a Fabric `preLaunch` entrypoint quarantines before any Minecraft code runs. The world folder comes from `level-name` in `server.properties`.
- **`SERVER_STARTING`** only captures the baseline (new world), re-locks and logs an `ERROR` for violations it could not prevent; it never moves anything.
- Integrated servers (singleplayer) are not enforced early.

## Commands

All under `/datapackblocker`, op-only (permission level 4):

| Command | What it does |
|---|---|
| `status` | Allowlist size and what sits in quarantine (with batch timestamp). |
| `verify` | Read-only audit: unreviewed, modified and missing packs. Use it before a `/reload` or to see what a restart would quarantine. |
| `approve <name>` | Moves the newest quarantined copy back, fingerprints, allowlists and locks it. Tab-completes quarantined names. Refuses to overwrite a pack already in the folder. Run `/reload` afterwards. |
| `unlock` | Restores owner write access on allowlisted packs for maintenance. |
| `lock` | Re-locks and **records the current contents as the new trusted fingerprint**. If you edit while unlocked and restart without `lock`, the edited pack is quarantined. |

## Upgrading from 1.0.0

A names-only allowlist is migrated in place on the first start: each present pack's *current* contents are fingerprinted and trusted. Verify them first if you doubt them.

## Scope and limitations

This is a tripwire for "someone drops a new pack in and the server restarts", not a security boundary:

- Anyone with shell/FTP access to the host (or root) can edit the allowlist or the packs.
- A pack present on the first run is trusted as-is.
- A pack added mid-session and picked up by `/reload` is only caught by `verify` or the next restart.
- Locking is best-effort: POSIX permission bits, or the read-only attribute on non-POSIX filesystems.
- Only directories and `.zip` files are treated as packs; hidden directories only if they contain `pack.mcmeta` (so `.git` is left alone).

## Why this exists

This complements the `packs/` maintenance-mode policy described in the repo root README: for servers that want to keep running existing datapacks but stop accepting new ones without review, this mod enforces that boundary automatically instead of relying on an operator remembering to check the folder by hand.
