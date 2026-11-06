# Security Policy

> [!CAUTION]
> **Datapacks have no security model.** They execute commands with the server's own authority, with no sandbox, no capability list, no signature and no audit trail. Never reproduce a reported issue **in a live world or on a production server**.

## Reporting a vulnerability

If you find a security issue in any project under this repository (Fabric
mods, datapacks, or helper scripts), please report it privately rather than
opening a public issue.

- Preferred: use [GitHub's private vulnerability reporting](https://github.com/vortaforge/core/security/advisories/new)
  for this repo.
- If that's not available to you, open an issue with minimal detail
  (e.g. "possible command injection in X, details sent privately") and we'll
  follow up for the specifics.

Do not include working exploit code or live payloads in public issues or pull requests (see "Prohibited content and practices" below).

Please include:
- Affected project/path (e.g. `mods/afk-manager`, `scripts/repo/datapack_guard.py`)
- Steps to reproduce, or a minimal example
- Impact (what an attacker could actually do)
- Minecraft/Fabric/Loom version, if relevant

We'll acknowledge reports as soon as we can and aim to have a fix or
mitigation out within a reasonable timeframe depending on severity. Low-risk
findings in archived/frozen projects (see below) may not get a fix, but will
be documented.

## Scope

This repo consolidates multiple projects with different security postures:

| Area | Status |
|---|---|
| `mods/` | Fabric mods. Compiled, type-safe. |
| `packs/` | **Empty since 2026-11-05.** The datapack programme was retired; every pack is audited, disarmed and frozen under `archived/packs/` (`archived/archive.json`). New datapack content is refused by `scripts/repo/datapack_guard.py`. |
| `scripts/` | Helper tooling. Treat as lower trust; review before running. |
| `examples/` | Templates and sample code. Not intended for production use. |
| `archived/` | **Every** retired project, kept for reference only — never deploy without review. Tracked in `archived/archive.json` (schema v2, every entry `"disarmed": true`); see `archived/README.md` and `docs/ARCHIVAL.md`. Nothing here is built, linted, tested or executed. |
| `blocklist/`, `scripts/repo/datapack_guard.py`, `datapacks.disabled.json` | The retirement's enforcement: account blocklist, fail-closed guard and kill switch. Weakening them is a security-relevant change. |

Datapacks and Fabric mods carry different security postures by nature; where
practical, security-sensitive logic belongs in a Fabric mod (compiled and
type-safe) rather than a datapack. That difference is one of the documented
reasons the datapack programme was retired: a datapack has no type system and
no enforced permission boundary, so stored-string command execution has to be
gated by hand in every pack. Projects that have stopped receiving updates are
frozen and marked archived rather than left in an inconsistent,
partially-hardened state.

## Validation tooling

`NOTICE.md` refers readers here for the tooling that validates a change. What
actually runs, and what each tool does and does not prove:

| Tool | Invoked by | Checks | Does **not** check |
|---|---|---|---|
| `scripts/repo/datapack_guard.py` | `pre-commit`, `pre-push`, and the `datapack-guard` job in `quality.yml`; `guardArchives` in `verifyProject` | No new datapack content, no revived archived tooling, no blocklisted accounts, kill switch engaged, registry consistent | Whether a rule should have an exception; whether an account is a datapack developer beyond the public-profile rule |
| `scripts/repo/check_archive.py` | `./gradlew checkArchive`, `scripts/repo/datapacks_disable.py verify`, the `datapack-guard` CI job | registry shape, hard-disable flags, path bijection, no workflows under `archived/`, empty `packs/` | Historical accuracy of a `reason` field |
| `python3 scripts/repo/datapacks_disable.py verify` | `datapack-guard` CI job, manual | switch + marker + registry agree, no live datapack tooling | Nothing runtime; it is a repository-state check |
| `python3 -m unittest discover -s scripts/tests` | `verifyProject` / the CI graph **when run** | guard/blocklist/switch behaviour, archive invariants, action pinning, common credential shapes, the static site's retirement notices | GitHub org settings, all secret types, runtime behaviour; see `scripts/README.md` for gaps |
| **Archived:** Spyglass + strict JSON (`archived/tools/datapack-lint/`), `checkPacks`, `checkOriginWatermarks`, `mergeDatapacks`, `build_release.py --check`, Ward (`archived/tools/ward/`) | nothing - archived 2026-11-05 | were the static/runtime datapack checks | not run any more; kept as reference for a future restore |
| `./gradlew buildAll` | `quality.yml` via `packageProject` in the `ci` graph | the **Gradle** subprojects (mods and other discovered Gradle projects) | Anything non-Gradle |

> **⚠️ Warning:** the Ward workflow (`ward.yml`) used to be the only place in this repository that started a Minecraft server. It is now archived at `archived/tools/ward/ward.yml` and inert, because GitHub only runs workflows under `.github/workflows/`. Nothing live in this repository starts, connects to or tests against a Minecraft server.

A green CI run therefore says the repository *parses and builds*, that the
datapack guard is engaged, and that the archive registry is consistent. It has
never said a datapack behaves correctly, which is why the datapacks were
retired instead of re-certified.

## Prohibited content and practices

The following are not accepted in this repository (code, issues, pull requests, documentation, examples, or releases) and are not recommended by any project in it. This applies **even when the stated intent is benign** (testing, education, "admin convenience", research).

### 1. Exploits for Minecraft or its ecosystem

- No exploit code, proof-of-concept payloads, or step-by-step exploitation guides for zero-day or unpatched vulnerabilities in Minecraft (client or server), Fabric, Forge/NeoForge, Paper/Spigot, other mod loaders, mods, plugins, or their dependencies.
- No weaponized use of known vulnerabilities such as Log4Shell (CVE-2021-44228) or similar injection and deserialization flaws. Describing a vulnerability class at a high level so that others can defend against it is fine; shipping a working chain is not.
- Vulnerabilities in third-party software should be reported to the vendor or upstream maintainer (for Minecraft itself, to Mojang/Microsoft) and not published here before a fix exists.

### 2. Prompt injection and AI-targeted payloads

- No payloads, text, or file content designed to manipulate AI assistants, code reviewers, or automated tooling that reads this repository (prompt injection), including instructions hidden in comments, metadata, item names, books, signs, or datapack/mod files.
- Reports about prompt injection weaknesses in a project's own AI-facing features are welcome through the private reporting channel above. Do not include working payloads in public issues.

### 3. Running operating-system commands from datapacks

- Datapacks cannot run PowerShell, Bash, `cmd`, or any other OS command on their own. Any method that claims to do so depends on an exploit, on a vulnerable, misconfigured or malicious mod or plugin, or on an external tool that executes console or chat output.
- We do not publish, accept, or recommend such methods, including "harmless" or "admin-only" variants, wrappers, bridges, or file-watcher setups that turn in-game commands, storage, signs, books, or command output into shell execution.
- Projects here must not depend on a component that provides in-game shell or file-system execution.

### 4. RCON

- **Malicious use:** RCON must never be used to gain, keep, or escalate unauthorized access to a server, and no code or documentation in this repo may help with that (for example brute-forcing, scanning for exposed RCON ports, or password guessing).
- **Legitimate use is discouraged and restricted.** RCON is not recommended by any project in this repo. A project may support it only if all of the following hold:
  - RCON is disabled by default (`enable-rcon=false`) and documented as optional.
  - It is bound to `127.0.0.1` or a firewalled, trusted network and is never exposed to the public internet.
  - A strong, unique `rcon.password` is used and is supplied through a secret store or environment variable, never committed to the repository or printed in logs.
  - It is never used as a bridge from a datapack, chat, or player input to a shell or the file system.
  - It is limited to the minimum set of commands the project needs.
- RCON-related security findings should be reported privately.

### 5. Enforcement

- Content that violates this section will be removed, and the related issue or pull request closed without a fix or discussion of exploit details.
- Repeated or deliberate violations may result in a ban from the repository.
- Archived and frozen projects are covered as well: their code is kept for reference only and is not an endorsement of any method listed above.

## Supported versions

Only the versions/branches actively referenced in each subproject's own
README receive security fixes. Archived projects (see table above) are
provided as-is.

## Third-party forks and converters

If you're using a fork, a "datapack to mod converter" output, or any
derivative of a project in this repo, verify it against the original source
here before trusting it — converted or forked artifacts are not covered by
this policy and may not reflect the same security posture.