# NOTICE

Read this before opening a pull request. It explains the mixed Gradle/
datapack layout of this monorepo and sets expectations for what a PR
should — and should not — contain.

## Repo layout, in short

This is a **monorepo**, not a single Gradle project with some extra files
next to it:

- `mods/` — Fabric mods. Each subproject is built and linted through the
  root Gradle build (`./gradlew ci -PconfirmZip=yes`, which runs
  `verifyProject` + `packageProject`; the narrower `buildAll` / `lint`
  tasks still work for a quick local pass). Changes here must build
  cleanly across **all** subprojects, not just the one you touched — a
  shared dependency bump or API change can silently break a sibling mod.
- `packs/` — **Empty. Datapacks are retired (2026-11-05).** Every pack, its
  generator, linter and test harness is archived and disarmed in
  `archived/archive.json`. `scripts/repo/datapack_guard.py` refuses new datapack
  content here, in `pre-commit`, `pre-push` and CI. See `docs/ARCHIVAL.md`.
- `scripts/` — Helper tooling, lower trust by default. Review before
  running locally.
- `examples/` — Templates and sample code. Not shipped, not covered by the
  same security posture as `mods/`. The datapack template was archived.
- `archived/` — Frozen, reference only, hard-disarmed.
- `blocklist/` — Account blocklist enforced by the guard.
- `scripts/git/hooks/` — `pre-commit` / `pre-push` guard hooks.

If your change spans both a mod and a datapack, it will be refused: the
datapack half cannot land. Say so in the PR description instead, so the
datapack part can be redirected to an issue.

## Gradle specifics

- JDK 25, wrapper included — don't add a second build system or bypass the
  wrapper.
- `./gradlew ci -PconfirmZip=yes` must pass before you request review.
  This is the exact task graph CI runs, in the single "Run canonical
  project CI task graph" step of the `Verify, test and package` job (see
  `.github/workflows/quality.yml`); there is no separate `buildAll`/`lint`
  step in CI to pass independently.
- When `ci` actually runs, `verifyProject` invokes the datapack guard, the
  kill switch, the archive-registry validator and the regression suites.
  Spyglass/JSON lint and the Ward runtime tests are archived with the packs and
  are not invoked any more (`archived/tools/datapack-lint/README.md`).
- Building a single subproject during iteration is fine
  (`./gradlew :mods:<subproject-name>:build`), but run the full `ci`
  before opening the PR — cross-subproject breakage is the most common
  thing missed by scoped builds.
- Avoid adding dependencies unless necessary; every added dependency is
  shared build surface for the whole monorepo, not just your subproject.

## Datapacks specifics

- **Datapacks are retired.** Do not submit one. `scripts/repo/datapack_guard.py`
  refuses new packs, new `.mcfunction` files and revived archived tooling in
  `pre-commit`, `pre-push` and CI (`datapack-guard` job), and
  `datapacks.disabled.json` is the switch that records the decision.
- Packs listed in `archived/archive.json` are frozen and disarmed. Fixes are
  not accepted either: re-enabling anything there is a deliberate, reviewed
  decision with a written reason (`docs/ARCHIVAL.md`).
- The reasons the programme was retired - no type safety, no security model,
  no debugging, no warnings, low review score, and real problems for a player
  using a datapack without any client mod - are recorded in
  `archived/README.md`. Read them before proposing a replacement.

## Do not misuse this project

This notice exists because of the nature of what's in this repo — datapack
macro systems, command-generation tooling, and Fabric mods that can touch
server/client behavior. To be explicit:

- Do not use anything in this repository to build griefing tools, cheat
  clients/mods, exploit kits, or anything designed to bypass another
  server's protections without authorization.
- Do not submit PRs that add obfuscated code, hidden network calls,
  backdoors, or any behavior not clearly described in the PR itself. A PR
  whose behavior doesn't match its description will be closed without
  further discussion, regardless of technical quality.
- Do not use this repo's macro/command-generation systems to build tooling
  intended to inject unsafe or attacker-controlled input into commands on
  a target server.
- Security-relevant contributions (anything touching namespace isolation,
  macro injection surfaces, or permission handling) should follow the
  private reporting process in `SECURITY.md` for the underlying issue
  first — don't post a working exploit in a public PR description.

Violation of the above is grounds for the PR being closed and, for repeat
or clearly malicious cases, the contributor being blocked from the repo.

## Before opening a PR

> **⚠️ Warning:** the Ward CI job that used to start an isolated, loopback-only Minecraft test server is archived (`archived/tools/ward/`) and inert. Do not start a server yourself for a PR check, and never run `archived/tools/ward/ward_ci.sh` anywhere.

- [ ] `git config core.hooksPath scripts/git/hooks` is set, so the guard runs locally
- [ ] `./gradlew ci` passes (it runs the guard and the archive checks)
- [ ] The PR does not add datapack content or revive archived tooling
- [ ] PR description explains **what** changed and **why**
- [ ] No unexplained dependencies, obfuscation, or behavior not covered by
      the description
