# vortaforge/core

Monorepo for VortaForge: **Fabric mods**. The Minecraft datapacks, resource
packs and the datapack tooling that used to live here are **archived and
hard-disabled** (2026-11-05) - see [Datapacks are disabled](#datapacks-are-disabled).

---
# 🚨 CRITICAL SECURITY RISK

> [!CAUTION]
> **CRITICAL SECURITY & PRIVACY ISSUE**
>
> BTK Decision No. 2023/DK-İD/119 introduces serious structural risks:
>
> - **Privacy:** Potential exposure of sensitive user data (Articles 12–13).
> - **Infrastructure:** Broad technical information disclosure requirements (Article 18).
> - **Availability:** Up to 90% network bandwidth throttling (Articles 22, 29, 32).
> - **Data security:** Increased data concentration risks (Article 13).
> - **Content integrity:** Potential over-removal of legitimate content (Article 36).
>
> **Impact:** Potential systemic consequences for users, developers, businesses, and digital infrastructure.
>
> **Classification: CRITICAL**
>
> *This assessment identifies structural risks, not confirmed security breaches or exploitable vulnerabilities.*
---

<!--
This opening line is the repository's GitHub description verbatim. Change one,
change the other:
  curl -X PATCH -H "Authorization: Bearer $TOKEN" \
    https://api.github.com/repos/vortaforge/core \
    -d '{"description": "<the new line>"}'
They had already drifted apart once ("Consolidated monorepo for the
vortacraftmc ecosystem."), which is circular - the organization *is*
the project name, so the description said nothing about what is in here.
-->

## Datapacks are disabled

> [!IMPORTANT]
> **The datapack programme in this repository is retired and hard-disabled.**
> `packs/` is empty, every datapack, generator, linter and test harness is
> archived and disarmed in [`archived/archive.json`](archived/archive.json), and
> [`datapacks.disabled.json`](datapacks.disabled.json) (`"enabled": false`) is
> the switch that keeps it that way.
>
> **Why:** datapacks here had no type safety (every value crossing a function
> call, storage read, scoreboard comparison or macro expansion is an untyped
> string), no enforced security model (stored-string command execution at
> `function-permission-level`), no debugging or inspection tooling, no warning
> or error surface, and a low review score. It was bad enough that it would have
> been better not to ship it at all. The maintainer also hit real problems as a
> plain player using a datapack with **no client mod installed**, and the same
> class of problems kept coming back in pull requests.
>
> **Blocked automatically:** new datapack content, new packs, revival of the
> archived tooling and blocklisted datapack developers are refused by
> `scripts/repo/datapack_guard.py` in `pre-commit`, `pre-push` and CI
> (`.github/workflows/quality.yml`, job `datapack-guard`).
>
> Read [`archived/README.md`](archived/README.md) for the policy and
> [`docs/ARCHIVAL.md`](docs/ARCHIVAL.md) for the whole system, including how to
> install it and how to re-enable it deliberately.

## Why datapacks are not accepted any more

> [!WARNING]
> **New datapack contributions are not accepted, in any form.** This is a
> permanent policy decision, not a temporary pause: pull requests that add
> `.mcfunction` files, a `data/<namespace>/` tree, a `pack.mcmeta`, a datapack
> generator or a datapack test harness are closed automatically by
> `scripts/repo/datapack_guard.py`. If a feature cannot be built as a Fabric mod, it
> is not built here.

The retirement list below is why. It is written from the maintainer's own
experience shipping, reviewing and *playing with* these packs — not from a
generic "vanilla vs modded" debate.

### 1. No type safety, anywhere

> [!CAUTION]
> Everything that crosses a boundary in a datapack is an **untyped string**.
> A function argument, a `data storage` read, a scoreboard value, a macro
> expansion, an NBT path — none of them have a type, a schema, or a compiler.
> A typo in a selector or a storage key is discovered at runtime, by the
> player, in the world.

| What a mod gives you | What a datapack gives you |
|---|---|
| A compile step (`javac`), types, generics | Nothing between your file and the world |
| IDE completion from the real API | Completion only if a third-party schema is current |
| Deterministic refactors | `grep` and hope |
| Unit tests that fail the build | Manual play-testing in a world |

A datapack's "type system" is a JSON schema maintained by volunteers. When
Mojang changes a format, the schema lags, the tooling lags, and the failure
mode is a silent no-op: the function runs and does nothing, or throws one line
into a log nobody reads.

### 2. The security model is not a security model

> [!IMPORTANT]
> Datapack code is executed by the server at `function-permission-level`
> (default 2). A pack that stores a string and later feeds it to `function`
> turns any writable surface — a sign, a book, a name tag, an anvil rename, a
> chat message, another pack's storage — into a **command execution surface**.

This is not theoretical in this repository: `macroEngine` and `TunnelScript`
both existed to execute user-authored command strings, which is why their own
documentation carried warnings that the content is "third-party content, not
audited, verified or endorsed". Once a pack can execute a string, the trust
boundary is whatever the weakest installed pack writes into storage. There is:

- **no sandbox** — the pack runs with the server's own authority;
- **no capability list** — nothing distinguishes "needs to read a scoreboard"
  from "needs `op`-level commands";
- **no audit trail** — a command is executed and the log records nothing by
  default;
- **no signature** — a datapack is a ZIP of plain files with no provenance.

Mods are not magically safe either (Java is arbitrary code), but a mod at least
has a reviewable source tree, a build artifact, a hash, and a loader that names
what it touches. A datapack has none of that and *still* executes commands.

### 3. No debugging, no inspection, no warnings

- There is **no debugger**. The only feedback is `/function` plus watching the
  world change.
- Errors are **one line in `latest.log`**, usually swallowed; a failed function
  call does not stop the caller.
- There is **no stack trace** and no call-site information — macro-expanded
  functions are unattributable once the string is built.
- There is **no lint** in vanilla. A whole ecosystem of third-party linters and
  language servers had to exist to approximate what `javac` gives for free; two
  of the packs here depended on exactly that tooling to stay coherent.
- **No coverage, no assertions, no CI-observable behaviour.** Testing meant
  standing on a server and clicking things.

> [!TIP]
> If you are looking for a rule of thumb: **anything you cannot write a failing
> test for before fixing is not engineering, it is a rehearsal.** That is the
> single biggest reason the programme is retired.

### 4. Low score on every axis that mattered

| Axis | Datapacks | Fabric mods |
|---|---|---|
| Type safety | none | Java |
| Security model | server authority, string execution | reviewed source + loader |
| Debugging | none | debugger, stack traces |
| Warnings / lint | third-party, version-lagged | compiler |
| Testing | manual, in-game | JUnit, CI |
| Client-side features | impossible | first class |
| Performance ceiling | command interpreter, per tick | native code |
| Upgrade cost | formats change every major version | mapped APIs |

### 5. The maintainer's own experience as a player

> [!NOTE]
> The decisive argument was not architectural. It was that using these datapacks
> **without a client mod installed** — the entire selling point of datapacks —
> still produced real problems: silent breakage, behaviour that depended on
> another pack in the same world, and no way to tell what had gone wrong. If the
> unique advantage of the platform does not survive contact with a normal
> player, the platform is not worth the cost.

The same class of problems kept arriving in pull requests, which is why the
guard now refuses the *shape* of the contribution rather than reviewing it each
time.

### What this means for contributors

> [!TIP]
> Bring a **Fabric mod**, not a datapack. `mods/` is where features live, the
> Gradle graph builds it, the tests run in CI, and the release pipeline ships
> the jar. See [`CONTRIBUTING.md`](CONTRIBUTING.md).

- Datapack-shaped trees, `.mcfunction` files, `pack.mcmeta` and datapack
  tooling are **refused by the guard** in `pre-commit`, `pre-push` and CI.
- Archived content is **frozen**: it can be read, it cannot be revived. Adding
  it back is a new project proposal, not a revert.
- Accounts on the [blocklist](blocklist/blocklist.json) are refused unless a
  maintainer adds the `datapack-approved` label — and that label does not
  override the account block itself.

## Structure

- `mods/`        — Fabric mods (Gradle subprojects, auto-discovered by `settings.gradle`)
- `packs/`       — **Empty.** Datapacks were retired on 2026-11-05; the guard refuses new content here.
- `archived/`    — Every retired project, frozen and disarmed: `archived/packs/`, `archived/tools/` (includes the archived `guigenmc` GUI-datapack generator), `archived/build/` (the datapack Gradle logic extracted from the root `build.gradle`), `archived/docs/`, `archived/examples/`. Registry: `archived/archive.json` (schema v2), validate with `scripts/repo/check_archive.py`.
- `blocklist/`   — Account blocklist (`blocklist.json`) enforced by the guard and mirrored org-wide by `vortaforge/.github`.
- `scripts/`     — Maintainer tooling, grouped by what it owns:
  - `scripts/repo/` — repository policy checks: the guard, the kill switch, the archive validator and the watermark checker.
  - `scripts/git/`  — versioned `pre-commit` / `pre-push` hooks (`git config core.hooksPath scripts/git/hooks`).
  - `scripts/ops/`  — operational helpers that a workflow calls, e.g. `backup-org.sh` (run by `backup-org.yml`).
  - `scripts/site/` — the PHP data-snapshot builder for the landing page.
  - `scripts/tests/`— offline regression tests for everything above.
- `docs/`        — Maintainer notes: [`docs/ARCHIVAL.md`](docs/ARCHIVAL.md) explains the retirement, [`docs/MAINTAINER_GUIDE.md`](docs/MAINTAINER_GUIDE.md) the rules, and [`docs/SCORECARD.md`](docs/SCORECARD.md) scores every part of the repository.
- `examples/`    — Example Fabric mods (the datapack template was archived)
- `build-logic/` — Shared Gradle script (`shared-fabric-mod.gradle`) applied by the mod subprojects
- `datapacks.disabled.json` — The kill switch (`"enabled": false`)

Content that does not fit another category is not given its own directory.
Register it in `archived/archive.json` with `"kind": "other"` instead; the
schema (`archived/archive.schema.json`) enumerates the valid kinds.

---

## Building

> **⚠️ Warning - a Minecraft server used to be started in exactly one place, and that place is archived.** The Ward (mcward) datapack test harness - `archived/tools/ward/ward_ci.sh`, `ward_guard.py` and its `ward.yml` workflow - was archived on 2026-11-05. The workflow is no longer under `.github/workflows/`, so GitHub does not run it, and nothing in the live repository starts, connects to or tests against a Minecraft server any more. Never run `ward_ci.sh` on a developer machine, a production host or next to a real world.

This repo uses Gradle to build all Fabric mod subprojects.

### Requirements

- JDK 25
- Node.js 20 (only for the offline website behaviour test) and Python 3 with pytest
- Gradle Wrapper (included, no separate Gradle install needed)
- Network access for initial dependency downloads

### Project lifecycle tasks

The root build exposes project-specific entry points in addition to the
per-module Gradle tasks:

```bash
# Guard (no new datapacks, no blocklisted accounts), kill switch, archive
# registry, repository regression tests. No Minecraft server is started.
./gradlew verifyProject

# Builds the Fabric modules and writes the project inventory.
./gradlew packageProject

# The canonical local CI graph: verifyProject + packageProject.
./gradlew ci

# Datapack-specific, all read-only:
./gradlew checkDatapackSwitch     # is the kill switch engaged?
./gradlew checkArchive            # is archived/archive.json valid and disarmed?
./gradlew printArchiveList        # what is archived, and why
python3 scripts/repo/datapacks_disable.py status
python3 scripts/repo/datapack_guard.py --staged --protect --blocklist
```

The datapack tasks (`zipPacks`, `mergeDatapacks`, `checkPacks`,
`lintDatapacks`, `checkProvenance`, `installDatapackLintDependencies`,
`testDpgen`, ...) **no longer exist**. Their implementation is archived verbatim
in [`archived/build/`](archived/build/) and [`archived/tools/`](archived/tools/).

`buildAll` and `lint` remain available as focused compatibility tasks: the
first builds every Gradle subproject, and the second runs configured Checkstyle
tasks. `writeProjectInventory` writes a deterministic build report at
`build/reports/repository/project-inventory.json`.

### Build a single subproject

```bash
./gradlew :mods:<subproject-name>:build
```

### CI

When enabled in GitHub, pushes, pull requests and manual dispatches can trigger
`build.yml`, named **CI**. The workflow was manually disabled at the
2026-10-29 status check; historical successful runs do not prove new runs are
occurring. Its read-only `quality` job calls `quality.yml`, the reusable workflow
that runs the canonical `./gradlew ci -PconfirmZip=yes` graph on Python 3.12.
The separate guigenmc build job was removed on 2026-11-05 with the package it
packaged. Every job behind the reusable workflow's
explicit quality gate must pass before its `verified` output is true; whether
GitHub *requires* that gate for a merge is a repository-ruleset setting, not
something this file can prove.

The `publish` job is **paused in the workflow file** pending a reviewed,
append-only design and recovery plan. Its disabled implementation has
`contents: write`, runs in the `release` environment and consumes the
release-candidate artifact rather than checking out repository code. An
environment name alone is not an approval: manual approval happens only if
required reviewers are configured for `release` in GitHub settings.

Workflow *enablement* is also a GitHub setting and is not stored in git. At the
2026-10-29 status check, CI, CodeQL, Reusable Quality, Organization Backup,
CODEOWNERS Sync and Ward were manually disabled. Check the current GitHub
settings and actual run records before claiming coverage. This change retires
the separate AI Agent workflow and implementation; previous green runs or AI
comments are not independent human reviews. See the
[maintainer guide](docs/MAINTAINER_GUIDE.md) for preserved project rules.

`verifyProject` runs the datapack guard, the kill switch, the archive registry
validation, focused repository safeguards, and the Python/Node regression
suites. `packageProject` builds the Fabric mods and writes the project
inventory. The old repository and GitHub audit scripts were removed; the
retained checks and important coverage gaps are listed in
[scripts/README.md](scripts/README.md).

Spyglass/JSON lint, the Ward runtime tests and the deterministic pack release
builder are **archived** with the packs they served; they are not run by any
build or workflow any more.

The separate `mods/rtwrapper-mod` and `mods/datapack-fixer` sources were
removed in the 2026-10-30 cleanup. The historical
`packs/RTWrapper/rtwrapper-fabric` source remains excluded from the Gradle
build; no RTWrapper Fabric mod is built as a replacement.

### Release ZIPs for the packs

Retired. `scripts/build_release.py` is archived as
`archived/tools/build-release/build_release.py`; its `dynamic-surfaces.json`
inventory and the `docs/dynamic-command-gate.md` contract it referenced are
archived under `archived/tools/build-release/` and `archived/docs/`.

## History

This monorepo consolidates projects that were previously scattered across
individual repositories under the `runtoolkit` GitHub organization
(TunnelScript, LeftClickDetection, dp-depman, RTWrapper, datapack-fixer, template-datapack, InteractionClickDetection,
cmdTunnel-datapack, dpgen, TEMPLATE-MOD, macroEngine, guigen). That
organization has since been retired; its projects moved to `vortacraftmc` and then to `vortaforge`. The old repos
are archived with a pointer to this monorepo, and are not otherwise
maintained.

> **Correction (2026-10-08).** Earlier revisions of this list also named
> `inv_gui`, and a later paragraph warned against using it because its
> licensing as a [rarula/Sketch](https://github.com/rarula/Sketch) fork had
> never been cleared. **No `inv_gui` pack has ever existed in this
> repository** - `git log --all --diff-filter=A -- '*inv_gui*'` returns
> nothing, and no directory, `pack.mcmeta` or namespace by that name is
> present. The warning was about a project that was discussed but never
> merged in, so both the list entry and the paragraph have been removed
> rather than kept as a caveat about absent code.

**Original source:** this project originated as [`runtoolkit/suite`](https://github.com/runtoolkit/suite)
by **Runtoolkit**. It is maintained here as `vortaforge/core`; the original
copyright notices in each `LICENSE`/`NOTICE` file are preserved.

