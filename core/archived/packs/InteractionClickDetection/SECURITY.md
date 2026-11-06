# Security Policy

This file was the untouched GitHub issue-template boilerplate: it still said
*"Use this section to tell people about which versions of your project are
currently being supported"*, and its version table declared `> 1.0.0`
supported and `< 4.0` unsupported - overlapping ranges that, for a pack whose
own `pack.mcmeta` says `v1.0.0`, described no coherent policy at all. A
placeholder that looks like a policy is worse than no file, because it reads as
an answer.

## Scope

This is a **datapack**, not a mod: it contains only `.mcfunction` files and
JSON. It runs with exactly the permissions of whoever loads it and cannot reach
the network, the filesystem or the operating system. The realistic risk surface
is therefore command construction, not code execution.

The specific thing to look at is macro expansion. Anything that builds a
command string from a value a player controls is a potential command-injection
point. See the root [SECURITY.md](../../SECURITY.md), section 3, for the
repository-wide rules on this.

## Supported versions

| Pack version | Minecraft (data pack format) | Status |
|---|---|---|
| 1.0.0 | 1.20.x (`pack_format: 26`) | No longer updated. Superseded by `packs/LeftClickDetection`. |

> **Note on the format number.** `pack.mcmeta` declares `pack_format: 26` while
> describing itself as "1.20.x". 26 is a **resource** pack format (24w06a); the
> data pack format for that era is a different number, and the two sequences are
> versioned independently. Correcting it is tracked with the repository-wide
> `pack.mcmeta` normalisation rather than here.

## Reporting a vulnerability

Do **not** open a public issue. Use
[GitHub's private vulnerability reporting](https://github.com/vortaforge/core/security/advisories/new)
for the repository, and include the pack path, the affected function, and what
an attacker who can trigger it would actually achieve.

Never include a working exploit or a live payload in a public issue or pull
request - see the root [SECURITY.md](../../SECURITY.md) for what is and is not
acceptable to publish.
