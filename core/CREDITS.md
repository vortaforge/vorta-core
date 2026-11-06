# Credits & AI-assistance disclosure

This file records which parts of the repository were written or changed with AI assistance, so that
AI involvement is visible in the repository itself and not only through commit authorship.

## 2026-11-02 - fix: guikitfw menu registry and docs, macroEngine rate_limit result, perm scratch cleanup and gate documentation

**Tool:** Claude (Anthropic), at the maintainer's request. **Anti-Review:** no independent human review had been recorded when this entry was prepared.

- `packs/guikitfw/README.md`: the Requirements line now matches `pack.mcmeta` (format 121 only, not "1.21+ / 121-122"); the `click_detection` row now describes what the code does (shift always, `"left"` opt-in via `internal/click/maybe_left`, drops independent of the key); added the `dynamic_cmd` config row, the `#guikit:while_on` tag row and a "Trust boundary" section.
- `packs/guikitfw/data/guikit/function/internal/click/detect.mcfunction`: comment only. Nothing calls this function; the comment now says so and points to `maybe_left`.
- `packs/guikitfw/data/guikit/function/runtime/put_menu.mcfunction`: appends an id to `guikit:lib order` only if it is not already listed, so re-registering a menu no longer grows the list. The list is only written, never read, in this pack.
- `packs/macroEngine-Datapack-v26.3/data/macroengine/function/systems/rate_limit/check.mcfunction`: sets `macroengine:output result` to `0b` before the gate checks, so a closed pack, a missing consent or a disabled `rate_limit` module no longer leaves an earlier call's value (for example `1b` written by `api/perm/require`, which uses the same key) for the caller to read. Behaviour change: those three cases now read as denied.
- `packs/macroEngine-Datapack-v26.3/data/macroengine/function/core/internal/systems/rate_limit/no_rule.mcfunction`: the module guard tested `modules{cmd:0b}`; it now tests `modules{rate_limit:0b}`.
- `packs/macroEngine-Datapack-v26.3/data/macroengine/function/api/perm/exec.mcfunction` and `run.mcfunction`: the permission verdict is read into a score (`#pex_deny`, `#pr_deny`) and the `_pex_tmp` / `_pr_tmp` scratch compound is removed right away, so the denial and dynamic-command-off exits no longer leave it in `macroengine:engine`. The allow/deny logic and the `dynamic_cmd` check are unchanged.
- `packs/macroEngine-Datapack-v26.3/README.md`: the "Is it safe?" FAQ and the Known Issues entry said the pack had no load gate or caller authorization; both now describe the load gate, consent gate, module switches, `dynamic_cmd` (default off), `cmd.dynamic`, the root blocklist, `perm_enforce` / `perm_cmd` defaults and what is still not covered, as documented in `docs/cmd_gate.md` and `docs/perm.md`.
- **Not performed:** no Minecraft server, Ward run or in-game test; `./gradlew ci`, `verifyProject`, Spyglass and the repository test suites were not run. The changes were read against the source only and checked with a script that resolves every `function macroengine:` / `function guikit:` reference and parses every JSON file. The `put_menu` list-match idiom (`{order:["<id>"]}`) and the `store success` score logic in `perm/exec` and `perm/run` are reasoned from the command semantics and are unverified at runtime.
- **Reported but not changed:** guikit's `$function $(fn)` and `$execute ... run $(cmd)` macro lines still do not validate their input (documented in the new README section instead); guikit's per-tick `@e[type=item,nbt=...]` scan and per-player redraw cost were not measured; `playeraction-rewrite-plan.md` says 82 files for `core/internal/player/` while the tree has 80; the `rate_limit/check` return value is 0 on the documented fail-open path (no rule) while `result` is `1b`.

## 2026-10-31 - docs(macroengine): regional-rules notice on the consent screen

**Tool:** Claude (Anthropic), at the maintainer's request. **Anti-Review:** no independent human review had been recorded when this entry was prepared.

- `packs/macroEngine-Datapack-v26.3/data/macroengine/dialog/gate/warning.json`: added a "REGIONAL RULES" block to the existing gate 3 consent screen. No new gate was added: the consent gate already requires players to read this screen and confirm before the pack activates for them.
- `packs/macroEngine-Datapack-v26.3/INFO.md`: new section 2b summarising, with article numbers, what BTK decision 2023/DK-İD/119 says about scope and who its duties address. The summary is based on the decision text supplied by the maintainer; it makes no claim that the rules apply or do not apply to any Minecraft server and is not legal advice.
- **Not performed:** no Minecraft server or in-game test; the dialog JSON was only checked for syntactic validity and the repository's offline tests.

## 2026-10-31 - fix: QuickShare cooldown guard and item placeholder; correct macroEngine finding

**Tool:** Claude (Anthropic), at the maintainer's request. **Anti-Review:** no independent human review had been recorded when this entry was prepared.

- `packs/QuickShare/data/quickshare/function/share.mcfunction`: the drop guard no longer fires during an active cooldown; drop and cooldown reset both test the cooldown as it was at function start; an empty main hand no longer starts a cooldown.
- `packs/QuickShare/data/quickshare/function/drop_mainhand_copy.mcfunction`: scratch item entity starts as a `minecraft:stone` placeholder instead of `minecraft:air`, and is overwritten from `SelectedItem` or killed.
- `docs/static-analysis-findings-2026-10-30.md`: QuickShare row updated; macroEngine `rnd_idx` note corrected (the objective is declared in `loader/scoreboards.mcfunction`).
- **Not performed:** no Minecraft server, Ward run or in-game test was used; the QuickShare behavior is reasoned from the command logic and the cited documentation only and is unverified at runtime. TunnelScript, LeftClickDetection, RTWrapper and the other macroEngine warnings were not touched.

## 2026-10-30 - chore: retire selected components and replace datapack lint

**Tool:** Arena.ai Agent Mode, at the maintainer's explicit request. **Anti-Review:**
no independent human review had been recorded when this entry was prepared;
local tests, bot comments and bypasses are not human approval.

- Removed only the four selected source paths (`mods/rtwrapper-mod`,
  `mods/datapack-fixer`, `packs/guikit-datapack`, `scripts/dp-depman`) and
  the two retired audit scripts; removed only their orphaned audit tests.
  Existing histories and credits are retained. Historical RTWrapper Fabric
  source remains excluded, so no RTWrapper Fabric mod is currently built.
- Replaced Mecha with a pinned Spyglass language-server client, a separate
  strict JSON parser, per-file coverage checks, security regression tests,
  explicit exceptions and a patched decompressor override. Retained selected
  audit safeguards in tests and documented their gaps. Corrected two invalid
  player selectors without claiming runtime validation.
- Preserved original license notices in individual and merged archives,
  corrected dpgen and PlayerAction licensing descriptions, and added tests.
  Ward tests stay in source but are omitted from runtime ZIPs. The merge dry
  run no longer clears prior build output. Updated active site, issue, build
  and maintainer references without deleting historical records.
- **Verified locally:** `./gradlew ci -PconfirmZip=yes` completed with JDK 25,
  Node 20, one worker and constrained JVM/Node heaps; some packaging tasks
  reused results from an earlier successful `packageProject` execution. The
  run included 49 repository Python tests, 65 guigenmc tests, 5 dpgen tests,
  6 linter tests and 52 Java tests (some Java tasks up-to-date). After adding
  dependency-license, symlink-discovery and generated-output regressions,
  all 51 repository tests and all 7 linter tests passed separately. The
  full graph passed before the final packaging guard and warning-label change;
  `packageProject`, the linter tests and an RTWrapper lint were rerun after
  those respective changes. Earlier runs lost their Gradle daemon under
  this sandbox's memory pressure; the successful run used lower limits.
  All 11 individual pack ZIPs and the merged ZIP were inspected, with source
  notices compared byte for byte; the macroEngine-specific ZIP was also checked.
  An isolated fixture confirmed generated root outputs are omitted while a
  legitimate nested `function/build` remains. Dry-run preservation
  and failing command/JSON/timeout fixtures were tested. Isolated Gradle
  fixtures rejected a symlinked notice, notice-directory collision and
  missing repository license. Actionlint 1.7.12 passed with only the
  intentional constant-false publishing-guard diagnostic filtered.
- **Open limitations:** the full lint covered 3,278 files at one inferred
  version per pack, with three Ward exclusions and 58 warnings. See
  `docs/static-analysis-findings-2026-10-30.md` for potential QuickShare,
  TunnelScript, LeftClickDetection, RTWrapper and macroEngine problems. No
  Minecraft server, Ward run, backup script, or GitHub Actions run was used;
  gameplay, all-version compatibility and permissions remain unverified.
  Publishing is still paused. No workflow enablement, stored repository or
  organization secrets, memberships, release assets or Git history were changed.

## 2026-10-29 - chore: retire repository AI automation

**Tool:** Arena.ai Agent Mode, at the maintainer's explicit request. Review status: _pending independent human review_.

- Removed the AI Agent workflow and implementation and the two AI-specific instruction files from this branch. This is a scoped removal, not permission to delete other project material or rewrite history.
- Preserved project safety rules and technical context in `docs/MAINTAINER_GUIDE.md`; updated active documentation references and regression tests without changing Ward's execution logic. Historical AI-disclosure entries in this file remain intact.
- Corrected live-status descriptions in `README.md` and `HANDOVER.md`: CI and CodeQL were manually disabled at the 2026-10-29 check, CODEOWNERS was absent, and the old Organization Backup script has unsafe deletion paths even in dry-run mode. The backup script and CODEOWNERS workflow themselves were not changed.
- **Verified locally:** 32 offline Python tests passed, with 3 socket/process tests deliberately deselected; archive-registry and provenance-watermark checks passed. The repository audit passed its high-severity threshold, retaining the two previously reported medium `pack.format-mixed` findings. Actionlint 1.7.12 passed after ignoring the diagnostic for the intentional constant-false publish guard; the Ward script passed `bash -n`. Ward execution logic was checked unchanged. The backup script, its workflow, the CODEOWNERS sync workflow, archive registry, CI, CodeQL and reusable-quality workflow files remained byte-identical to the base.
- **Not performed:** no workflow settings, GitHub secrets, provider keys, memberships, rulesets or release assets were changed, and no existing Git history was rewritten. The branch adds new commits normally. GitHub Actions, full Gradle CI and independent human review are not claimed. No Minecraft server or backup script was run.

## 2026-10-29 - fix: pause destructive release publication

**Tool:** Arena.ai Agent Mode. Review status: _pending independent review_.

- **Incident and correction:** the earlier governance change introduced automatic removal of release assets that were absent from the current build. Following the merge of PR #53, the `Remove stale packs-latest assets` step in CI run `40905618629` completed successfully; `guikit-demo.zip` and `RTWrapper-1.21.1.zip`, previously inventoried in that release, were no longer listed. This conflicted with the maintainer's no-deletion instruction. The agent accepts responsibility for proposing that step; this entry preserves rather than rewrites the earlier record.
- The publishing job is disabled while the read-only quality workflow remains enabled. The explicit deletion step has been replaced by a report that preserves older assets. `overwrite_files: false` is a further guard, **not** proof that the upstream release action has no destructive cleanup paths; publication must remain paused until a separately reviewed append-only design is ready.
- The earlier CODEOWNERS sync change explicitly removed `.github/CODEOWNERS` inside its runner before switching branches. The sync step now uses a separate detached worktree and a normal non-force push instead; explicit runner-temporary `rm` commands were also removed.
- Historical copies of the two ZIPs were located in CI artifact `12555914631` (CI run `40085083586`) built from commit `9b89eb11c9dee7bf09cb838cb0e52d2fa2210b0d` on 2026-10-24. The artifact archive matched GitHub's recorded SHA-256 digest and its two inner ZIPs matched its own `SHA256SUMS`. They have not been proven byte-identical to the removed release assets, and their original download counts cannot be recovered by a simple re-upload.
- **Historical-source correction:** `git ls-tree 58c05eb9^ -- packs/guikit-demo packs/RTWrapper-1.21.1` confirms that both pack directories did exist in the repository history before commit `58c05eb9`. The older claim below that they had never existed in the monorepo was wrong and remains below only as the original audit trail.
- **Verified locally:** the CODEOWNERS sync step was exercised against an isolated bare remote for a new branch, a fast-forward update, a no-op, and preservation of the original checkout; the release report was exercised with mock API results including an API failure; changed Bash blocks passed `bash -n`; actionlint 1.7.12 passed with its warning about the deliberate constant-false publish guard explicitly ignored; `pytest -q scripts/tests/test_repo_invariants.py` passed (16 tests).
- **Not verified:** release recovery to GitHub, the deleted assets' original byte digests, any future append-only publisher, the full Gradle CI graph, or Minecraft runtime behavior.

## 2026-10-29 - fix: CODEOWNERS access and review record follow-up

**Tool:** Arena.ai Agent Mode. Review status: _pending independent review_.

- **Correction to the governance entry below:** the claim that both named code owners had repository write access was not established. The previous empty `codeowners/errors` response was obtained while the default branch did not contain the restored CODEOWNERS file; an empty result in that state is not proof that a proposed owner has write access. After PR #53 was merged, GitHub's endpoint reported eight `Unknown owner` errors for `@IronCrest-sudo` on the restored rules.
- The same eight path patterns remain. The active owner is `@tickwarden`, the owner that GitHub did not flag in that response. `@IronCrest-sudo` remains documented for historical context, not as an active code owner, until repository write access is verified. Re-check access before changing owners; listing an account does not establish independent review or successor acceptance.
- PR #53 was merged by `tickwarden` on 2026-10-29. The GitHub reviews API returned no reviews when checked after the merge. **Anti-Review:** no independent approval is recorded on GitHub; this statement does not rule out discussion or review outside GitHub. This follow-up does not manufacture an approval and does not claim that a ruleset bypass was used.
- A PR authored by the only active code owner still needs an independent reviewer where review is required. Neither this correction nor successful CI supplies a human review.
- **Verified locally:** the eight CODEOWNERS path patterns are unchanged and the historical account name remains in a comment; `git diff --check`, `check_archive.py`, and `origin_watermarks.py --check` passed; `scripts/audit_repo.py` reported only the two pre-existing `pack.format-mixed` medium findings; `pytest -q scripts/tests/test_repo_invariants.py` passed (14 tests).
- **Not verified:** a live GitHub CODEOWNERS validation for this follow-up branch, because the branch had not yet been pushed when this entry was prepared; runtime Minecraft behavior and the full Gradle CI graph were not tested for this documentation/configuration-only change.

## 2026-10-29 - docs: maintainer handover preparation

**Tool:** Arena.ai Agent Mode, working from the maintainer's request to prepare the project and organization for transfer to a successor. Review status: _pending independent review_.

| Path | Change |
|---|---|
| `HANDOVER.md` | New transfer runbook: preferred organization-owner handover model, asset and automation inventory, credential-name inventory without values, successor acceptance criteria, transfer-day checklist, post-transfer verification, and abort conditions. It states explicitly that preparation is not a completed transfer and that no successor is the owner until they accept and the checklist is recorded. |
| `README.md` | Added a dated maintenance-status note linking to `HANDOVER.md` and keeping responsibility with the current maintainer until the handover completes. |

- **Verified:** public GitHub account, organization, repository, contributor, fork, open-pull-request, and branch-head data were re-checked on 2026-10-29; the governance commit was replayed onto the then-current `main`, which had deleted `.github/CODEOWNERS`, and the corrected CODEOWNERS file was restored deliberately rather than accepting the delete side of the conflict. Documentation and credential-name claims were checked against the workflow tree.
- **Not verified / not performed:** no branch was pushed and no GitHub membership, billing, repository ownership, secret, environment, Pages, ruleset, or pull-request state was changed from the preparation environment. No candidate has accepted ownership merely by being named in an outreach draft. No Minecraft server was started.

## 2026-10-29 - fix: governance, workflow-security and consistency pass

**Tool:** Arena.ai Agent Mode, working from the maintainer's request to audit PR #52, the phantom review gate, repository inconsistencies and stale references. Review status: _pending - update when reviewed_.

| Path | Change |
|---|---|
| `.github/CODEOWNERS`, `.github/workflows/codeowners-sync.yml` | Replaced the duplicate `*` rules (the second line overrode the first, leaving the PR author as the only effective owner) with the scoped generated form naming both write-access owners on each rule. The sync workflow now derives owners from repository collaborators with push access instead of organization membership and appends a normal commit to its branch instead of force-pushing. |
| `.github/pull_request_template.md`, `CONTRIBUTING.md` | The template now names the canonical `ci` command, drops the non-existent commit-hook claim, and requires an explicit review status: an independent write-access/code-owner review, or “not independently reviewed (Anti-Review)” when a maintainer bypass is used. A bot comment, green CI or bypass must not be called a human approval. |
| `.github/scripts/ai-agent.js`, `scripts/tests/test_repo_invariants.py` | Removed the agent's generic Python/Node/binary runners and external fetch/search tools. The fixed read/search/check tools remain; file writes are allowed only on `workflow_dispatch`, and `.git/`, `.github/`, Gradle build controls, the named check scripts and credential-looking paths are write-blocked. Added a regression test for that policy. |
| `.github/workflows/build.yml` | Release text no longer claims that naming the `release` environment is itself an approval. After publishing the rolling `packs-latest` release, the write job now removes assets that are no longer produced, so removed packs do not remain downloadable as stale release assets. Repository history and source files are not touched by that step. |
| `scripts/audit_full.py`, `scripts/tests/test_repo_invariants.py` | List-endpoint API failures (for example an exhausted anonymous rate limit) are now recorded as “section not audited” findings instead of crashing while iterating an error dictionary. A missing local `core` clone is likewise reported instead of raising `FileNotFoundError`. |
| `.github/dependabot.yml`, `.github/workflows/backup-org.yml` | Comments now match configured behaviour: Dependabot version updates are enabled with a limit of 9, not paused at 0; the backup token note describes the collaborator-list scope used by CODEOWNERS Sync. |
| `README.md`, `CLAUDE.md`, `AGENT.md`, `SECURITY.md`, `scripts/README.md`, `archived/README.md` | Removed or qualified claims that did not match the live tree/settings at audit time: no Python 3.9 CI job exists, the AI Agent and Ward workflows were manually disabled, GitHub Pages was not enabled, the release environment is not automatically an approval, the validation-tool invocation paths are the current `build.yml` -> `quality.yml` -> Gradle graph, and `packs/` holds 12 pack directories. |
| `index.html`, `.nojekyll`, `scripts/gui_generator/pyproject.toml`, `scripts/dp-depman/scripts/depend_edit.py`, `packs/RTWrapper/docs/API.md` | Updated the user-facing brand to VortaForge, added `.nojekyll` so enabling the intended static Pages source does not ask Jekyll to process the monorepo, replaced the non-existent `guikit-demo.zip` fallback card with `guikitfw.zip`, pointed guigenmc package URLs at this repository instead of a 404 repository, made the dp-depman example URL explicitly illustrative, and marked the unshipped `vortacraftmc:` registry/status design as not present in the RTWrapper tree. Runtime identifiers and provenance history were deliberately not renamed (CLAUDE.md rule 8). |
| PR #52 (the proposed “Power Tools” workflow on `tickwarden-patch-1`) | **Not merged or copied into this branch.** The proposed workflow adds arbitrary `bash`, `git filter-repo` and force-push operations under a `contents: write` token, contrary to CLAUDE.md rule 1; its dry-run guard for history rewriting also prints an error without exiting. The recommended disposition is to close PR #52 without merging. Closing it is a GitHub-side action and was not performed from the audit environment. |

- **Verified:** `actionlint` 1.7.7 passed for every workflow in this tree; `node --check .github/scripts/ai-agent.js`; `bash -n` passed for 22 extracted workflow `run:` blocks; the CODEOWNERS collaborator `jq` filter was tested against a representative payload; the non-force CODEOWNERS branch update was exercised against an isolated bare remote; the stale-release-asset step was exercised with a mock `gh`; `python3 scripts/audit_repo.py` (only the two pre-existing `pack.format-mixed` mediums remain), `check_archive.py`, `origin_watermarks.py --check`, and `build_release.py --check` passed; Python tests passed (97), dpgen Node tests passed (5), and Mecha datapack lint passed; `./gradlew verifyProject` passed on Temurin 25.0.5 with `--no-daemon`, one worker and a reduced heap.
- **Not verified:** the full `./gradlew ci -PconfirmZip=yes` graph was not run because `packageProject` was outside the audit sandbox's 1.9 GiB memory budget (the root build defaults to `-Xmx4G`); no Minecraft server was started; Python 3.9 itself was not run (the local interpreter was 3.13 and CI is 3.12); no GitHub setting, ruleset, environment, Pages state, release asset or PR state was changed from the audit environment. After this branch is pushed, re-check GitHub's CODEOWNERS errors endpoint and the live ruleset before describing the review gate as active.

## 2026-10-29 - fix: macroEngine consistency pass (docs vs code, archive flag, cross-pack notes)

**Tool:** Claude (Anthropic), claude.ai chat, working from the maintainer's request to review `packs/macroEngine-Datapack-v26.3`, fix inconsistencies and make it work with the other packs. Review status: _pending - update when reviewed_.
**Not verified:** nothing was run in a Minecraft server (repo rule). Checked statically only: Mecha lint (`scripts/lint_datapacks.sh`), `origin_watermarks.py --check`, `audit_repo.py`, JSON parse of `merge-manifest.json`, and a reference scan of every `function` / function-tag target in `packs/`. The Gradle build (`verifyProject`, `mergeDatapacks`) was **not** run (no network access to the Gradle distribution here). Mecha skips the `$` lines of macro functions, so the one macro line changed (`api/interaction/remove`) was read, not validated.

| Path | Change |
|---|---|
| `.../function/config.mcfunction` | The archive flag `#vortacraftmc.archivedpacks.macroengine` defaulted to `1` although its comment called it opt-in, and the banner that reads it (`core/internal/load/main`) uses `@s` in a load context with no executor, so it never reaches anyone. Default is now `0`. Worlds that already stored `1` keep it; the banner code is unchanged. |
| `.../function/api/interaction/remove.mcfunction` | `$kill` now also requires `tag=macroengine.interaction`, so a tag shared with another pack's interaction entities is not removed. **Behaviour change** for callers that relied on removing non-macroEngine interactions by tag. |
| `.../api/cmd/freeze.mcfunction`, `.../core/internal/api/cmd/freeze/tick.mcfunction` | Comments pointed at a non-existent `#macroengine:events/on_tick` and a wrong function path; they now name `#macroengine:loop` and the real path. Comment-only. |
| 5 function files (`core/cooldown/reset_all`, `core/lib/once_per_player_reset`, `core/lib/schedule_cmd`, `player/is_online`, `systems/hook/on_advancement_fire`) | Remaining Turkish comment words translated (repo rule: English only). Comment-only. |
| `docs/config.md` | Added the `module_block` and `module_container` rows (both keys exist in the schema, are seeded and applied, and are guarded by 8 and 9 functions, but were undocumented). |
| `THIRD_PARTY_LICENSES.md` | Link to `playeraction-rewrite-plan.md` pointed at `docs/`; the file is in the pack root. |
| `README.md` | Removed the claim that VortaForge is "temporarily archived" (reverted by the 2026-10 unarchive pass); linked the new interop page. |
| `docs/interop.md` (new) | Cross-pack surface that already exists in the code: `gate/is_open`, extension tags, storage rules, known conflicts. Documentation only. |
| `docs/dynamic-command-gate.md` (repo root) | Removed the claim that Ward tests `data/macroengine/test/cmd_gate_*` exist; that directory does not. |
| `packs/merge-manifest.json` | `output.min_format` / `max_format` `[121,1]` -> `[121,0]` to match the included packs (AGENT.md rule; 26.3 is data pack format 121.0 per public sources). |

- **Not changed on purpose:** the `player_action.*` runtime identifiers (see `docs/interop.md` section 5; needs a migration plan under CLAUDE.md rule 8), the `#vortacraftmc.*` fake players (rule 8), and the 13 `$(invoke)` helper functions that `docs/dynamic-command-gate.md` already lists as deliberately outside the gate.

## 2026-10-28 - fix: macroEngine test findings (uuid output, summon_cbm position, consent screen, permission switches)

**Tool:** Claude (Anthropic), claude.ai chat, working from the maintainer's written test report (five findings, tested on Minecraft 26.3 with two accounts). Review status: _pending - update when reviewed_.
**Not verified:** nothing here was run in a Minecraft server (repo rule: no server tests by an agent). Checked statically only: Mecha lint (`scripts/lint_datapacks.sh`, passed), `origin_watermarks.py --check` (ok), `audit_repo.py` (two findings that were already there: `pack.format-mixed` in RTWrapper and guikitfw). Mecha skips the `$` lines of macro functions, so those lines were read, not validated; the other lines of all macro functions were checked in a temporary copy with the `$` lines removed.

| Path | Change |
|---|---|
| `packs/macroEngine-Datapack-v26.3/.../systems/uuid/*`, `.../core/internal/systems/uuid/*`, `.../systems/hook/raycast/found.mcfunction` | `uuid/from_entity`, `from_array`, `recall` and `match` now put their result in `macroengine:output uuid` (`recall_array`: `macroengine:output uuid_array`) instead of overwriting `macroengine:input value`. **Breaking for outside code that read `macroengine:input value` after these calls.** Internal readers (`store`, `match`, hook `placed.uuid`) were moved. Two Turkish `KULLANIM` headers translated. |
| `.../input/summon_cbm.mcfunction` | The command block minecart is killed/summoned `at @s`, so `execute as <player> run function macroengine:input/summon_cbm` places it at that player and not at whoever typed the command. |
| `.../gate/consent_route.mcfunction` (new), `gate/permit_grant`, `gate/approve` | After the pack is approved, the consent screen opens only for the approver (or the `execute as` target). Other unconsented players get a chat notice with a click action; players who join later still get the screen. A console/command-block approval opens no screen. |
| `.../api/perm/require`, `api/perm/check`, `config.mcfunction`, `core/config/{apply,ensure}`, `systems/cmd_gate/check`, `api/toggle/perm/*` (new: `enforce_on/off`, `default_on/off`, `cmd_on/off`, `status`), `docs/perm.md` (new), `docs/config.md` | New config keys `perm_enforce` (follows `perm_default`, ships on) and `perm_cmd` (ships off); `config_rev` 3 -> 4. With enforcement or `module_perm` off, `require`/`check` pass for everybody (before, `module_perm` off made every `require` fail). `cmd_gate` calls `require` with `in.strict` and is never opened by these switches. Toggle functions accept a no-entity executor or the `macroengine.admin` tag. |
| `.../api/cmd/**` (121 wrappers) | Each wrapper gets two lines that require the permission `cmd.<name>` when `perm_cmd` is on. Skipped: `empty`, `run_with_cb`, `data_remove_storage`. Default is off, so behaviour does not change until a server enables it. |

## 2026-10-27 - feat: default-off dynamic command gate + deterministic release build

**Tool:** Arena.ai Agent Mode, working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

| Path | Change |
|---|---|
| `packs/macroEngine-Datapack-v26.3/data/macroengine/function/systems/cmd_gate/` | New fail-closed gate for stored-string command execution: config switch, `cmd.dynamic` permission via `api/perm/require`, length/control-character checks, and a developer-controlled root-token blocklist (`blocklist.mcfunction`, seeded only when missing). The command string is only ever handled as storage data - no macro line in the gate touches it. |
| `packs/macroEngine-Datapack-v26.3/data/macroengine/function/api/perm/group/`, `.../core/internal/api/perm/group/` | Permission groups on top of the existing `perm.<name>` tags: admin-only create / grant-perm / assign / remove / list, every name checked with `systems/validate/safe_name` before it reaches a macro line. |
| `packs/macroEngine-Datapack-v26.3/` (executors + config) | All stored-string executors (queue, hooks, wand, triggers, `multi_cmd`, `once_cmd`, region watchers, command-block runners) now call the gate; `api/cmd/*` string runners and `api/perm/run|exec` read the same new config keys `dynamic_cmd` (default `0b`) and `dynamic_cmd_max_len` (`config_rev` bumped to 3). The fake "safely executed via pipeline" step in `multi_cmd/exec_macro` now runs the real check. Supporting docs in `docs/cmd_gate.md` and `docs/config.md`; two Ward tests under `data/macroengine/test/`. |
| `packs/guikit-datapack/`, `packs/guikitfw/` | Stored menu commands are off until an operator sets `guikit:cfg dynamic_cmd` to `1b` (default seeded in `core/load`). |
| `packs/RTWrapper-v1.0.1/`, `packs/RTWrapper/` | The single wrapper dispatch is off by default (`#dynamic`, `rtw.config`); `rtwrapper:api/dynamic/on|off` toggles it. |
| `packs/TunnelScript/`, `packs/cmdTunnel-datapack/` | The legacy command-block runners are off by default (`#dynamic_enabled` / `#dynamic`), on top of the existing trusted-tag and confirmation gates; pre-macro syntax only, so the packs stay loadable on their target versions. |
| `scripts/build_release.py`, `scripts/tests/test_build_release.py` | New release pipeline: one deterministic ZIP per pack (release copy minified, source untouched, nothing renamed, `_vc_origin` kept verbatim, Ward `test/` folders excluded) plus `SHA256SUMS.txt` and a line-by-line inventory of dynamic command-execution surfaces. No obfuscation or encryption by design. |
| `docs/dynamic-command-gate.md`, `README.md`, `SECURITY.md`, `scripts/lint_datapacks.sh` | Cross-pack inventory of every dynamic surface (including the code-supplied `$(invoke)` helpers and prefix-constrained dispatches reviewed and deliberately not gated, and the packs with no surface), enable instructions per pack, and the new lint ignore for the macroEngine Ward tests. |

- **Verified:** `scripts/lint_datapacks.sh` (Mecha 0.101.0) passed; `./gradlew :checkPacks` on Temurin 25
  (`--configure-on-demand`, memory-capped) checked 12 packs / 3217 functions with 0 errors and 0 warnings;
  `python3 -m unittest discover scripts/tests` - 28 tests OK (including the new build_release tests);
  `python3 scripts/origin_watermarks.py --check` passed; `python3 scripts/audit_repo.py` reports only the two
  pre-existing `pack.format-mixed` notes; `python3 scripts/build_release.py --check` passed and all 12 release
  ZIPs were built and spot-checked; every static `function` reference in the changed files resolves.
  The finished diff was also written out as a `.patch`, applied to a fresh clone with `git apply`, and the
  same checks re-run there (the patch file itself is not part of the tree).
- **Not verified:** no Minecraft server was started (CLAUDE.md rule 7). The two new Ward tests are written but
  unrun - their first execution is the `ward.yml` CI job. The gate's runtime semantics (permission, blocklist,
  group assign/remove against live players) still need the in-world acceptance pass from `NOTICE.md`. The full
  `verifyProject`/`ci` graph was not run: configuring the Fabric Loom subprojects exhausts the sandbox's
  2 GiB of RAM, so only `checkPacks` ran in isolation.

## 2026-10-23 - feat: add ten guikit condition types

**Tool:** Copilot SDK in VS Code, working from a prompt by the maintainer. Review status: _pending - update
when reviewed_.

| Path | Change |
|---|---|
| `packs/guikit-datapack/data/guikit/function/cond/` | Added biome, health, hunger, air-supply, fire, ground, sneaking, sprinting, swimming, and elytra-flight conditions; wired them into condition dispatch and composition. |
| `packs/guikit-datapack/data/guikit/predicate/cond/` | New player-state predicates for fire, ground, sneaking, sprinting, swimming, and elytra flight. |
| `packs/guikit-datapack/data/guikit/dialog/page.json`, `packs/guikit-datapack/data/guikit/function/play/tab_visual.mcfunction` | Added an editor option for page tabs and active-page highlighting. |
| `packs/guikit-datapack/README.md`, `packs/guikit-datapack/data/guikit/function/help.mcfunction`, `packs/guikit-datapack/pack.mcmeta` | Documented the v6 features and updated the pack version description. |

- **Verified:** `./gradlew verifyProject` passed in a Python 3.12 environment with pytest, Mecha 0.101.0, and the local editable `guigenmc` package; the pinned Mecha datapack lint, `python3 scripts/origin_watermarks.py --check`, and `git diff --check` passed.
- **Not verified:** no live Minecraft server or bot was started; the repository prohibits local server tests.

## 2026-10-20 - docs: macroEngine README overhaul, PlayerAction rewrite plan

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update
when reviewed_.

| Path (under `packs/macroEngine-Datapack-v26.3/`) | Change |
|---|---|
| `README.md` | Rewrote the project-history header to cover the full organization chain (runtoolkit → vortacraftmc → VortaForge), both archived and neither deleted; added an explicit AI-disclosure line; expanded Installation into platform-specific sections (manual/UI, Linux/macOS Bash, Windows PowerShell, generic server install, Claude Code/agent-assisted install). |
| `THIRD_PARTY_LICENSES.md` | Linked the PlayerAction "scheduled for removal" status to the new rewrite plan document. |
| `docs/playeraction-rewrite-plan.md` | New. A phased plan (not implementation) for removing the `core/internal/player/` PlayerAction dependency, based on reading the current 82-file tree. Separates the dependency into a low-risk namespace-only portion (lifecycle + state/statistics + advancement-relay pairs) and the one subsystem that actually carries PlayerAction-specific technique (click detection via a tracked invisible `interaction` entity). Records two candidate designs for that subsystem without choosing between them, per the maintainer's instruction to leave that decision open. |

- **Verified:** read-through of all 82 files under `core/internal/player/`, its 12 predicates and 27 advancement JSONs, to produce the scope breakdown in the plan document. No code in `core/internal/player/` was changed.
- **Not verified:** the rewrite plan itself is unimplemented and untested — no click-detection code was written, ported, or run. The Installation section's platform-specific commands (Bash, PowerShell, Claude Code instructions) were written from general knowledge of Minecraft datapack install mechanics and were not executed against a live server in this session. Nothing was run in a Minecraft server.

## 2026-10-19 - ci: reusable quality gate and artifact-only publishing

**Tool:** Arena.ai Agent Mode, working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

| Path | Change |
|---|---|
| `.github/workflows/quality.yml` | New reusable, read-only quality workflow. It runs the canonical Gradle `ci` graph on Java 25/Python 3.12/Node 20, guigenmc Python 3.9 compatibility tests, source/wheel checks, bounded artifacts and an explicit all-jobs gate. Release assets include a SHA-256 manifest. |
| `.github/workflows/build.yml` | Reduced the public CI entrypoint to a reusable-quality caller and an approval-gated publish job. The only writable job does not check out or execute repository code; it verifies the SHA-256 manifest and publishes only the gated ZIP artifact. |
| `scripts/audit_repo.py`, `scripts/tests/test_repo_invariants.py` | The documentation audit discovers Gradle tasks in root-owned `build-logic/` scripts; offline regression coverage now guards the reusable-workflow trust boundary as well as SHA-pinned actions. |
| `README.md`, `CLAUDE.md` | Updated CI documentation to match the reusable quality and artifact-only publication design. |

- **Verified:** YAML parsed with PyYAML; `python3 scripts/audit_repo.py --format github --fail-on high` passed with one existing medium RTWrapper warning; offline regression tests: 18 passed.
- **Not verified:** GitHub Actions execution, release-environment approval and publishing have not run. No Minecraft server was started.

## 2026-10-19 - feat(build): project-level Gradle lifecycle tasks

**Tool:** Arena.ai Agent Mode, working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

| Path | Change |
|---|---|
| `build-logic/project-tasks.gradle`, `build.gradle` | New project-specific Gradle task graph: provenance, audit, offline Python tests, guigenmc tests, locked dpgen install/tests, datapack lint, `verifyProject`, `packageProject`, `ci`, and a deterministic project inventory report. Existing task names remain intact for compatibility. |
| `scripts/audit_repo.py` | Pack roots are now discovered recursively from `pack.mcmeta`, aligning the audit with the Gradle pack tasks and validating RTWrapper's nested distributable pack instead of reporting its source container as broken. |
| `README.md`, `CLAUDE.md`, `AGENT.md` | Documented the canonical Gradle lifecycle commands and their offline-only scope. |

- **Verified:** with JDK 25, `./gradlew tasks --group verification`; `./gradlew verifyProject` passed all 10 offline tasks, including Mecha, 65 guigenmc tests, 5 dpgen tests and 18 repository tests. `checkPacks` reports 29 existing external-reference warnings; the audit reports one existing medium RTWrapper format warning.
- **Not verified:** `packageProject` reached archive generation and initial Fabric compilation, but the sandbox Gradle daemon was killed during Loom remapping even with one worker and a 1.5 GiB heap cap. The complete package/CI graph and GitHub Actions workflow therefore still need a hosted-runner confirmation. No Minecraft server was started.

## 2026-10-19 - feat: macroEngine `tui/` text UI module

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update
when reviewed_.

### Changed (AI-assisted edit)

| Path (under `packs/macroEngine-Datapack-v26.3/`) | Change |
|---|---|
| `data/macroengine/function/tui/{line,header,divider,button}` | New. Print a line, title bar, rule and clickable function button to `@s`. Text is read from `macroengine:tui` storage and rendered with `api/store/render`. |
| `data/macroengine/function/core/internal/tui/{render_text,render_label,render_hover,button_send}` | New. Internals. `button_send` is the only macro line; its single argument `fn` is validated with `systems/validate/function_id` first. |
| `docs/tui.md`, `README.md` | New doc; one feature bullet. |

- **Verified:** Mecha 0.101.0 passes with the new files; text components set `interpret:false` and `plain:true`; click/hover use the 1.21.5+ field names.
- **Not verified:** nothing was run in a Minecraft server (repository rule). The click/hover rendering, the `execute if function` chain into `api/store/render` and the `$tellraw` macro were checked by reading, not executing. The module has no `config` on/off switch.

## 2026-10-19 - fix: macroEngine hover_event field names and missing `plain` on NBT text components

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update
when reviewed_.

### Changed (AI-assisted edit)

| Path (under `packs/macroEngine-Datapack-v26.3/data/macroengine/function/`) | Change |
|---|---|
| `systems/string/hover_text`, `systems/string/tag_badge` | **Fix.** `hover_event` / `show_text` still used the pre-1.21.5 `contents` key; it is `value`. The component did not match the 1.21.5+ format. |
| `systems/string/tooltip_item` | **Fix.** `hover_event` / `show_item` used `contents:{id,Count}`; the 1.21.5+ format is flat `id` and `count`. |
| `api/store/show`, `api/store/player/show`, `api/title/actionbar_p`, `core/internal/api/title/_apply`, `core/config/list` | **Fix.** Six `nbt` text components lacked `plain` (and in two lines `interpret`/`plain` pairs), so string values printed with quotes on 26.1+. Applied with `scripts/fix_text_components.py --fix`; the script now reports 0 remaining. |

- **Verified:** Mecha 0.101.0 passes on the pack (the two documented `time query` files excluded as in `lint_datapacks.sh`); `scripts/origin_watermarks.py --check` ok; `pytest scripts/tests` 17 passed; every pack JSON file (loot tables, item modifiers, recipes, advancement triggers) checked against the vanilla registries of misode/mcmeta (snapshot 26.4-snapshot-4, slightly newer than 26.3) with no findings; all 1085 `function` references resolve.
- **Not verified:** nothing was run in a Minecraft server (repository rule). The `hover_event` field names follow the 1.21.5+ text component format and were not exercised in game. No new features were added: the stable commands from 1.21.5 to 26.3 (`/waypoint`, `/dialog`, `/fetchprofile`, `/compute`, `/posteffect`) have no matching API module in this pack.

## 2026-10-18 - fix/ci/test: restore macroEngine watermark, pin remaining actions, add repository tests

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update
when reviewed_.

### Changed (AI-assisted edit)

| Path | Change |
|---|---|
| `packs/macroEngine-Datapack-v26.3/data/macroengine/function/_vc_origin.mcfunction` | Restored with `scripts/origin_watermarks.py --write`. Commit `5f2a74b` had deleted it, so `--check` (the first CI step) failed on `main`. Only this one file was written. |
| `.github/workflows/ai-agent.yml`, `codeql.yml` | `actions/checkout`, `actions/setup-node` and `github/codeql-action/{init,analyze}` pinned by commit SHA (were floating tags), as `CLAUDE.md` required. SHAs resolved with `git ls-remote` against the upstream repositories. Historical note: the AI Agent workflow was removed later. |
| `scripts/tests/test_repo_invariants.py` | New. Offline regression tests: real tree passes the watermark check; missing/hand-edited watermarks are rejected (on a temporary copy); every workflow `uses:` is SHA-pinned. |
| `.github/workflows/build.yml` | New required step "Repository tests" (guigenmc pytest suite, `scripts/tests`, `scripts/check_archive.py`), wired into the release gate, diagnostics and the final summary. These tests existed but CI never ran them. |
| `scripts/lint_datapacks.sh` | Excluded paths are now found with `-prune`, each one is reported once with its `.mcfunction` count, and the summary prints the total number of files excluded from validation. Exit-status behaviour is unchanged. |
| `packs/DailyBonus/data/dailybonus/function/tick.mcfunction` | **Fix.** A player with no `db_last_day` score was never granted (a score comparison against an unset score never succeeds), so the daily bonus could never be claimed for the first time. One line added before the existing comparison; the existing line, namespaces, objectives and loot table are unchanged. Not verified in a running game: the regression is covered by a Ward test that only runs in CI. |
| `packs/DailyBonus/data/dailybonus/test/*.mcfunction` (3 files) | New Ward tests (load constant, tick day, first login is granted). Excluded from Mecha lint (`scripts/lint_datapacks.sh`) because `assert`/`await` are not vanilla commands; the exclusion is reported like the others. Written from Ward's documentation, never executed. |
| `.github/workflows/ward.yml`, `scripts/ward_ci.sh`, `scripts/ward_guard.py`, `scripts/tests/test_ward_guard.py` | New. Isolated Ward job (see below); 16 offline tests in `scripts/tests` cover the guard (fake loopback / `0.0.0.0` listeners) and keep the workflow, script and docs from being loosened. |
| `CLAUDE.md`, `AGENT.md`, `README.md`, `CONTRIBUTING.md`, `NOTICE.md`, `SECURITY.md`, `scripts/README.md` | Rule 7 now names the single Ward exception; warning notes added. |
| `scripts/dpgen/test/builder.test.js`, `scripts/dpgen/package.json` | New. 5 offline `node:test` tests (examples validate and build, tick/load tags, invalid configs raise `ConfigError`); `npm test` was a placeholder that always failed. Also run by the CI "Repository tests" step. |

- **Verified (run in a sandbox, not in CI):** `origin_watermarks.py --check` (fails before the restore, passes after); `pytest` 81 passed (65 guigenmc + 16 in `scripts/tests`); orchestration against a stub `mcward` in 5 scenarios (loopback pass, `0.0.0.0` aborts before tests, test failure propagates, no tests fails, bypass flag); every negative control failed as intended; `npm test` in `scripts/dpgen` 5 passed (a deliberately wrong expectation made one fail); the SHA-pin test fails when one action is unpinned again; `scripts/lint_datapacks.sh` with Mecha 0.101.0 exits 0, and exits 1 with a deliberately malformed function (removed afterwards); `check_archive.py`; JSON/YAML parse of every tracked file; `py_compile`, `bash -n` and `node --check` on all scripts.
- **Not verified:** `./gradlew buildAll`, `build` and `lint` were not run (sandbox has JDK 21, the repo needs JDK 25, and Gradle/Loom downloads are outside the allowed network). The new CI step has not run on GitHub Actions. Nothing was run in a Minecraft server (repository rule).
- **`mcward==1.4.0` is integrated as an isolated, CI-only job (maintainer-authorised exception to the no-server rule):** `.github/workflows/ward.yml` + `scripts/ward_ci.sh` + `scripts/ward_guard.py`. Server bound to `127.0.0.1`, whitelist enforced and empty, online-mode on, status/query/RCON off; seeded before start, proven loopback-only before and after the tests, inbound 25565 dropped when iptables is available, stopped and deleted in an always-run cleanup. Warning notes added to `CLAUDE.md`, `AGENT.md`, `README.md`, `CONTRIBUTING.md`, `NOTICE.md`, `SECURITY.md`, `scripts/README.md`, the workflow and both scripts, guarded by tests. **Never executed against real mcward or a real server** (sandbox: Python 3.12, no Mojang/Modrinth/Adoptium access); only the guard and the orchestration were tested, against a stub `mcward` and plain Python sockets. **The job fails until a pack contains Ward tests** (`data/<ns>/test/**.mcfunction`); none exist. Whether Ward builds exist for 26.3 and whether the server needs the Minecraft EULA (not accepted by the workflow) is unverified.

## 2026-10-18 - feat: macroEngine `cb/run_repeating`, `cb/time_left`, `container/info`

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update
when reviewed_.

### Changed (AI-assisted edit)

| Path (under `packs/macroEngine-Datapack-v26.3/`) | Change |
|---|---|
| `data/macroengine/function/api/cb/run_repeating`, `core/internal/api/cb/repeat_build` | New. Repeats one command 1..100 times at a fixed interval by building a `cmds` list and reusing `systems/cb/seq_expand`. |
| `data/macroengine/function/api/cb/time_left`, `core/internal/systems/cb/time_left_step` | New. Read-only: ticks until the next pending entry of a `cb_id`, plus the pending count. |
| `data/macroengine/function/api/container/info` | New. Size, used, free, empty, full and first free slot in one call; reuses the existing `_addr`, `_count`, `_size_pick` and `_ff_loop` internals. |
| `docs/cb.md`, `docs/container.md` | Document the new functions; `container.md` is new and also lists the existing container functions. |

- **Verified:** `scripts/lint_datapacks.sh` (Mecha 0.101.0) passes with the new files. `scripts/origin_watermarks.py --check` still reports the missing macroEngine watermark; that was already the case before this change and is untouched.
- **Not verified:** nothing was run in a Minecraft server (repository rule). The `first_free` scan and the `time_left` counters were checked by reading the code paths they reuse, not by executing them. `cb_time_left` for an entry pushed back by the fire spacing reports its current counter, not its real fire tick.

## 2026-10-15 - feat: macroEngine load gates 4 and 5, two item tags, four block tags

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update
when reviewed_.

### Changed (AI-assisted edit)

| Path (under `packs/macroEngine-Datapack-v26.3/data/macroengine/`) | Change |
|---|---|
| `function/gate/load_guard`, `load_begin`, `load_end`, `loads_decay`, `clear_incomplete`, `clear_tripped`, `set/4_on`, `4_off`, `5_on`, `5_off` | New. Gate 4 (incomplete-load gate) and gate 5 (reload-loop gate), both default on. |
| `function/gate/version`, `refresh`, `status`, `function/setup` | Initialise gates 4/5, call `gate/load_guard`, close `#macroengine.open` for both gates, print their state, bracket the load with `load_begin` / `load_end`. |
| `tags/item/books`, `tags/item/buckets` | New item tags. |
| `tags/block/command_blocks`, `chests`, `containers`, `workstations` | New block tags (first block tags in this pack). Not added to `tags/item/all.json`. |

- **Verified:** Mecha 0.101.0 on the pack (without the two files the lint script already ignores) reports no errors; every new JSON file parses.
- **Not verified:** nothing was run in a Minecraft server (repository rule). Block and item IDs were written from knowledge of vanilla, not checked against a 26.3 registry dump. Gate 4 only detects a setup that did not reach its last line; it does not see a failing command inside a finished setup. The 6-loads-in-1200-ticks threshold for gate 5 is a guess, not measured.

## 2026-10-12 - docs: fix stale function paths in macroEngine usage comments

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update
when reviewed_.

### Changed (AI-assisted edit)

| File | Change |
|---|---|
| `packs/macroEngine-Datapack-v26.3/.../api/cmd/time_of.mcfunction` | Usage comment named the old `ame:clock_handler`; now `macroengine:api/cmd/time_of`. |
| `.../api/macro/with_advancement`, `with_function`, `with_score` | Usage comments pointed to `macroengine:engine/macro/...`; now `macroengine:api/macro/...`. |

- **Verified:** Mecha 0.101.0 on the macroEngine datapack (comment-only change, no command lines touched).
- **Not verified:** nothing was run in a Minecraft server. Known and left unchanged: `api/cmd/other/action_run` substitutes `$(player)`, `$(type)`, `$(arguments)` into a macro line without `systems/validate/safe_name`; `systems/rate_limit/config` documents `delete` and `list` functions that do not exist.

## 2026-10-10 - refactor: remove dead `multiCommands` storage writes in macroEngine

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update
when reviewed_.

### Changed (AI-assisted edit)

| Path | Change |
|---|---|
| `packs/macroEngine-Datapack-v26.4/.../api/cmd/other/multi_cmd.mcfunction` | Removed `data remove` of `macroengine:engine multiCommands.type` / `.active`; nothing in this call path sets either. |
| `packs/macroEngine-Datapack-v26.4/.../api/cmd/other/multi_cmd_adv.mcfunction` | Same two `data remove` lines removed. |
| `packs/macroEngine-Datapack-v26.4/.../multi_cmd/advanced/run_with_options.mcfunction` | Removed the only writer of `multiCommands.type` (and its "Validate" comment, which described validation that does not exist). Nothing in the repository reads the value. |

### Verification status

- Verified: repo-wide grep shows no remaining reader of `multiCommands.type` / `.active`; `scripts/lint_datapacks.sh` (Mecha 0.101.0) passes.
- **Not verified:** runtime behaviour in a real Minecraft server. Datapacks or tools outside this repository that read `macroengine:engine multiCommands.*` would be affected.

## 2026-10-11 - retarget to Minecraft 26.3

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

| Path | Change |
|---|---|
| `packs/macroEngine-{Datapack,Resourcepack}-v26.3/` | Renamed from `-v26.4`; `pack.mcmeta` now data pack format 121.0 / resource pack format 97.1; version string `v26.3`, meta score 263; README updated |
| `packs/{DailyBonus,QuickShare,RTWrapper-v1.0.1,guikit-datapack,guikit-demo}/pack.mcmeta` | format 122 -> 121 |
| `packs/LeftClickDetection/pack.mcmeta` | `supported_formats` array -> object form |
| `index.html`, `scripts/*`, docs | path and label updates for the rename |

Verification: Mecha lint, `audit_repo.py`, `check_archive.py` and the `index.html` zip-list check pass.
**Not verified:** loading on a real Minecraft 26.3 server; that nothing in the 26.4-snapshot content relies on data pack format 122 features; Fabric/Gradle builds.

## 2026-10-07 - fix: release assets not found (`packs-latest`)

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update
when reviewed_.

### Changed (AI-assisted edit)

| Path | Change |
|---|---|
| `.github/workflows/build.yml` | `release` job: `files:` now points to `release-assets/*.zip` (the downloaded `release-packs` artifact) instead of `build/packs-dist/*.zip` / `build/dist/*.zip`, which do not exist in that job (no checkout). Added `fail_on_unmatched_files: true` and a duplicate-file-name check in "Collect release assets". |

### Verification status

- Verified: YAML parses; duplicate-name check logic exercised locally with a shell test.
- **Not verified:** an actual GitHub Actions run (needs a push to `main` / `workflow_dispatch`).

## 2026-10-04 - improvements batch + two new Fabric mods

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Reviewed and merged by a human
maintainer (review status: _pending at the time of writing - update when reviewed_).

### New (AI-written; every new Java file carries an "AI-assisted" header comment)

| Path | What |
|---|---|
| `mods/join-throttle/` | Login-rate limiter mod (1.21.1, Yarn) incl. unit tests |
| `mods/afk-manager/` | Idle detection / `/afk` / optional AFK kick mod (1.21.1, Yarn) incl. unit tests |
| `CREDITS.md` | This file |

### Changed (AI-assisted edits to existing files)

| Path | Change |
|---|---|
| `mods/rtwrapper-mod/build.gradle` | `project.archivesBaseName` (removed in Gradle 9) -> `base.archivesName` |
| `build-logic/shared-fabric-mod.gradle` | Reproducible archives (no timestamps, stable file order) |
| `build.gradle` | Removed ~235 lines of blank padding (whitespace only) |
| `settings.gradle` | Deterministic (sorted) subproject discovery order |
| `mods/TEMPLATE-MOD/gradle/wrapper/gradle-wrapper.properties` | Gradle 9.4.1 -> 9.8.0 (matches root) |
| `.github/workflows/build.yml` | Top-level `permissions: contents: read` (least privilege) |
| `.github/dependabot.yml` | `pip` pointed at the real manifest dir; added `npm` for `scripts/dpgen` |
| `scripts/check_archive.py` | Parity with Gradle `checkArchive` + type guards instead of crashing |
| `scripts/backup-org.sh` | Token passed to `github-backup` via a 0600 temp file instead of argv |

### Verification status at the time of writing

- Verified by running: `check_archive.py` (real registry + malformed inputs), `backup-org.sh` (stubbed
  `github-backup`), YAML parsing of the changed workflow files, and the unit tests of the Minecraft-free
  classes of both new mods.
- **Not verified (no Gradle / Fabric Maven access in the authoring environment):** Gradle configuration of
  all changed `.gradle` files, compilation of the Fabric-facing code (`*Mod.java`, `PlayerManagerMixin`)
  against Minecraft 1.21.1 Yarn mappings, and runtime behaviour in a real server. Treat these as
  needing a CI run and a manual server test before release.

## index.html: escape error messages in the warning banner

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

| File | Change |
|---|---|
| `index.html` | `errors` entries (which can contain `err.message` and the release `tag_name` returned by the GitHub API) were concatenated into `innerHTML` unescaped; each entry now goes through `escapeHtml()` before rendering. |

- **Not verified:** rendering in a real browser; only the string replacement and its uniqueness were checked.

## Organization migration to vortaforge (links and provenance text)

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

| Area | Change |
|---|---|
| Repo URLs | `github.com/vortacraftmc/...`, `vortacraftmc/core` and `vortacraftmc.github.io` replaced with the `vortaforge` equivalents in docs, scripts, Gradle files, `index.html` (`OWNER`, cache key) and metadata. |
| Provenance | `scripts/origin_watermarks.py` template now states runtoolkit -> vortacraftmc -> vortaforge; all 20 `_vc_origin.mcfunction` files regenerated with `--write`, `--check` passes. |
| Deliberately unchanged | Datapack namespaces (`data/vortacraftmc/`), scoreboard fake players (`#vortacraftmc.*`) and the Java package `com.vortacraftmc`: renaming them would break existing worlds or APIs and needs a separate migration decision. The `runtoolkit` origin statements are kept on purpose. |

- **Not verified:** Gradle build and CI run; the target org does not exist yet, so no link was checked online.


## License alignment: Unlicense everywhere

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

Decision (maintainer): the project is Unlicense; older repos that carried MIT are private and archived.

| File(s) | Change |
|---|---|
| `scripts/origin_watermarks.py` + 20 `_vc_origin.mcfunction` | Header now says Unlicense instead of MIT; regenerated, `--check` passes. |
| `packs/{DailyBonus,LeftClickDetection,InteractionClickDetection,cmdTunnel-datapack,QuickShare}/NOTICE` | MIT line replaced with Unlicense. |
| `scripts/gui_generator/pyproject.toml` | `license` and trove classifier changed to Unlicense. |
| `examples/opmod-example` | `LICENSE` replaced with the root Unlicense text; `fabric.mod.json` license set to Unlicense (was CC0-1.0). |
| `packs/macroEngine-Datapack-v26.4/README.md` | Removed the note about the inconsistent MIT header, which no longer applies. |

- **Left as is on purpose:** third-party MIT/other licenses (`THIRD_PARTY_LICENSES.md`, `jszip.min.js`, `package-lock.json`).
- **Not verified:** legal effect; this is not legal advice.

## macroEngine: storage-based `api/store/*` module, `api/placeholder/*` deprecated

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

| Path | Change |
|---|---|
| `packs/macroEngine-Datapack-v26.4/data/macroengine/function/api/store/**` | New public module: global and per-player variables (`set/get/has/remove/add/default`), multilingual templates (`text/define`, `text/remove`) and `render`, which returns a plain string. |
| `.../core/internal/api/store/**` | Internals. Names and language keys go through `systems/validate/safe_name` before any macro line; player keys are built from the UUID ints only. |
| `.../api/placeholder/*` | Marked deprecated in the file header; most functions now print a one-time admin notice. Behaviour is unchanged. `parse`, `actionbar*` and `load` stay silent because `api/title/*_p` and `setup` still call them. |
| `docs/store.md`, `README.md` | Documentation and migration table. |

- **Verified:** Mecha 0.101.0 parses the new files without errors (the only two errors in the pack are the existing `time query minecraft:day` lines, which this Mecha version does not know).
- **Not verified:** nothing was run in a Minecraft server. In particular `%player%` and `%score:...%` rely on the existing `to_plain` helper (text_display trick) and the module has never been executed. Treat it as untested.

## SEO files, CLAUDE.md and removal of the store self-test

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

| Path | Change |
|---|---|
| `index.html` | Meta description, robots, canonical, Open Graph/Twitter tags, JSON-LD (`SoftwareSourceCode`), `<noscript>` summary and a "not affiliated with Mojang/Microsoft" footer line. |
| `robots.txt`, `sitemap.xml` | New; point at `https://vortaforge.github.io/core/`. |
| `CLAUDE.md` | New project guidance for Claude Code. |
| `packs/macroEngine-Datapack-v26.4/.../api/store/selftest.mcfunction` | Removed at the maintainer's request (no in-game tests). |

- **Not verified:** how Google indexes the page (Search Console not available); JSON-LD and sitemap were only parsed for well-formedness. The target Pages site does not exist yet.

## Authors, copyright lines and contact metadata

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

| Path | Change |
|---|---|
| `mods/*/fabric.mod.json`, `packs/RTWrapper/rtwrapper-fabric/.../fabric.mod.json` | `authors` entry `vortacraftmc` -> `VortaForge` (the `Runtoolkit (original source)` credit is kept); `contact.sources` now `https://github.com/vortaforge/core`. `datapack-fixer` gained a `contact` block. |
| `packs/*/NOTICE`, `scripts/origin_watermarks.py` (+ 20 regenerated watermark headers) | Copyright holder now `Legends11 / VortaForge (formerly Runtoolkit)` / `VortaForge (formerly Runtoolkit)`. |
| `packs/DailyBonus`, `packs/QuickShare` `pack.mcmeta` | Description credits VortaForge. |
| `scripts/gui_generator/pyproject.toml`, `scripts/dpgen/package.json` | Author set to `VortaForge`. |
| `packs/macroEngine-Datapack-v26.4/README.md` | Maintainer links point at VortaForge. |

- **Left as is:** `TEMPLATE-MOD` and `opmod-example` placeholder authors (`Me!`, `you`), third-party copyright (`THIRD_PARTY_LICENSES.md`), `maven_group` / Java packages (`com.vortacraftmc`).
- **Maintainer to confirm:** the exact legal name to use as copyright holder; I used the existing `Legends11 / ...` form from the older NOTICE files.

## banner.png converted to a real PNG

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

`banner.png` was a JPEG with a `.png` extension and a long EXIF description string. It is now a real PNG (same 1408x736 picture, no metadata). The image itself was not redesigned.

## macroEngine: `api/store/show` and `api/store/player/show`

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

| Path | Change |
|---|---|
| `packs/macroEngine-Datapack-v26.3/data/macroengine/function/api/store/show.mcfunction`, `.../api/store/player/show.mcfunction` | New. Call `get` / `player/get` and print the value to `@s` with an NBT `tellraw` (`interpret: false`). `get` itself stays silent. |
| `packs/macroEngine-Datapack-v26.3/docs/store.md` | Documents `show` and printing `out.value` after `get`. |

- **Verified:** `scripts/lint_datapacks.sh` (Mecha 0.101.0) passed.
- **Not verified:** nothing was run in a Minecraft server.

## macroEngine: store/data merge, placeholder module removed, functional config; org references

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

| Path | Change |
|---|---|
| `packs/macroEngine-Datapack-v26.3/.../api/data/*` | Moved to `api/store/nbt/*`; the scratch keys are now `macroengine:store nbt.value` / `nbt.result` (was `macroengine:data value` / `result`). `docs/data.md` merged into `docs/store.md`. There was no `api/nbt` module. |
| `.../api/placeholder/**`, `.../core/internal/api/placeholder/**`, `docs/placeholder.md` | Removed. `to_plain` resolved `{selector:"@s"}` through a text_display, where `@s` is the display and not the player; `send*` and `actionbar*` only printed to chat. |
| `.../core/internal/api/store/_tok_score*`, `_player_name`, `_tok_ent` | `%score:obj%` reads the scoreboard directly; `%player%` resolves a tagged selector through a short-lived text_display and keeps only the string; new `%health%`, `%food%`, `%xp_level%`, `%dimension%` read entity data. |
| `.../api/store/convert`, `render_all`, `show`, `player/show` | New. Strings, ints, bytes and lists of strings only; `show` prints with an NBT `tellraw`. |
| `.../api/title/show_p`, `actionbar_p`, `core/internal/api/title/_apply` | Rebuilt on `api/store/render`; titles are plain strings printed with `interpret: false`. |
| `.../config.mcfunction`, `core/config/*`, `core/tick*`, `core/tick/dispatch`, `systems/log/set_level` | Config keys `enabled` and `namespace_allowlist` removed (nothing read them); `tick_rate`, `hud_rate`, `admin_rate`, `log_level`, `reload_warn` now drive the tick, dispatch and log systems. `exec`, `score_get`, `score_set`, `set_int`, `set_default`, `has`, `delete`, `config/tick_cfg` and the `macroengine.config` objective removed. See `docs/config.md`. |
| Workflows, scripts, `settings.gradle`, `pack.mcmeta` descriptions, README | Stale `vortacraftmc` / `VortaCraftMC` references changed to `vortaforge` / `VortaForge`. |

- **Kept on purpose:** runtime identifiers (`data/vortacraftmc/`, `#vortacraftmc.*` fake players, `com.vortacraftmc`; CLAUDE.md rule 8) and provenance text (`runtoolkit -> vortacraftmc -> vortaforge`, "Original source: Runtoolkit", NOTICE source URLs, `archived/archive.json`).
- **Verified:** `scripts/lint_datapacks.sh` (Mecha 0.101.0), `scripts/origin_watermarks.py --check`.
- **Not verified:** nothing was run in a Minecraft server. In particular `%player%`, the `tick_rate` divider and the new config functions were never executed in game.

## macroEngine: `systems/nbt` removed, schema-driven runtime config

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

| Path | Change |
|---|---|
| `.../systems/nbt/*`, `.../core/internal/systems/nbt/*` | Removed. Nothing in the repo called them; `api/store/nbt/*` covers the same ground except `first`, `move` and `swap`, which now have no equivalent. |
| `.../config.mcfunction`, `core/config/*` | 54 config keys with a schema (`config_schema`): module switches, tick systems and rates, handler intervals, queue depth, store limits and token switches, title defaults, name length. `set` and `get` are table-driven and validate against the schema; `ensure` uses a revision marker (`config_rev`). |
| 376 files under `api/<module>/` and `systems/<module>/` | One guard line each: `execute if data storage macroengine:engine modules{<module>:0b} run return 0`. `validate`, `toggle`, `flag` and `systems/color` are not guarded. |
| `systems/flag/toggle_system`, `.../flip` | Rewritten. The old `exec` flipped the score 1 to 0 and back to 1 in one call, so it never toggled anything. |
| `api/toggle/<module>/true,false` | Write `config.module_<module>` and apply it. |
| Scans, queue, store, title, validator | The hook, geo, interaction, wand and perm-trigger scans honour `*_interval`; the queue honours `queue_max_depth`; `api/store/render`, `_dispatch`, `_resolve`, `_find_tpl`, `api/title/show_p` and `safe_name` read their limits from the config. |

- **Verified:** `scripts/lint_datapacks.sh` (Mecha 0.101.0), `scripts/origin_watermarks.py --check`.
- **Not verified:** nothing was run in a Minecraft server. The module guards, the `%` interval counters and every `core/config/*` function are untested in game.


## Datapacks: Gate 1 (version gate) on format-121 packs

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

| Path | Change |
|---|---|
| `packs/{DailyBonus,QuickShare,guikit-datapack,macroEngine-Datapack-v26.3,RTWrapper-v1.0.1}/data/<ns>/function/gate/version.mcfunction` | New. Creates the `vortaforge.gate` objective and sets `#<ns>.version` to 1. |
| Each pack's load entry (`load`, `core/load`, `setup`) | First executable line calls `<ns>:gate/version`. |
| Each pack's tick entry (`tick`, `core/tick`, `core/trigger_tick`) | First executable line: `execute unless score #<ns>.version vortaforge.gate matches 1 run return 0`. |

- **What it is:** a safeguard against partial or mixed installs (tick running without the pack's own load). It is not a sandbox and not tamper-proof: a datapack is plain text and the line can be deleted. Non-bypassable checks belong in a Fabric mod. Gates 2-4 (permission check, player consent, age declaration) are planned in later PRs; the age gate can only be a player's own declaration, not verification.
- **Not covered:** legacy packs (`pack_format` below 48, `functions/` directory naming), `guikit-demo` (no tick entry), `archived/`.
- **Verified:** `scripts/lint_datapacks.sh` (Mecha 0.101.0), `scripts/origin_watermarks.py --check`.
- **Not verified:** nothing was run in a Minecraft server. Load order and `return 0` behavior in game are untested.

## Datapacks: Gate 2 (trigger permission), toggles, simple packs excluded

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

| Path | Change |
|---|---|
| `packs/{guikit-datapack,macroEngine-Datapack-v26.3,RTWrapper-v1.0.1}/data/<ns>/function/gate/*` | `version` rewritten as a real version gate (downgrade protection: inactive when the world was last saved by a newer pack version). New: `permit_prompt`, `permit_tick`, `permit_grant` (approval through `/trigger <ns>.permit set 1`, no cheats, no `allowCommands`, no `/op`), `approve`, `revoke`, `status`, `set/1_on`, `1_off`, `2_on`, `2_off`. |
| Load entries (`core/load`, `setup`, RTWrapper `core/trigger_load`) | The version gate now also ends the load function with `return 0`. |
| Tick entries (`core/tick`, RTWrapper `core/trigger_tick`) | Version check, permission check and the permission tick, each bound to `return 0` and each skippable with `gate/set/N_off`. |
| `packs/DailyBonus`, `packs/QuickShare` | Gate 1 removed again: no input handling, no macros, no command execution, so no gate. |

- **Defaults:** both gates on. An updated world stays inactive until a player approves with `/trigger <ns>.permit set 1` (or an operator runs `<ns>:gate/approve`).
- **Limits:** `/trigger` is not authenticated; on a server with untrusted players any player can approve. Datapack gates are removable plain text; real enforcement belongs in a Fabric mod. Gate 3 (per-player consent) and Gate 4 (age declaration, a self-declaration, not verification) are not part of this PR.
- **Verified:** `scripts/lint_datapacks.sh` (Mecha 0.101.0), `scripts/origin_watermarks.py --check`.
- **Not verified:** nothing was run in a Minecraft server. `click_event` text, `/trigger` flow, load order and `return 0` behavior are untested in game.

## Datapacks: gate line in every function of the complex packs

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

| Path | Change |
|---|---|
| `packs/{guikit-datapack,macroEngine-Datapack-v26.3,RTWrapper-v1.0.1}/data/*/function/**` (2166 files) | First executable line: `execute unless score #<ns>.open vortaforge.gate matches 1 run return 0`. The separate version and permission return lines are folded into this one line. |
| `.../gate/refresh` | New. Recomputes `#<ns>.open` (1 only when every enabled gate passes); called from `version`, approve/revoke/grant and the `set/*` toggles. |
| `.../gate/rerun_load`, `permit_grant`, `approve` | Load entries are blocked while the pack is not approved, so approval schedules a re-run of them one tick later. |
| `.../gate/status` | Also prints `open`. |

- **Not gated:** `gate/*` itself, `_vc_origin.mcfunction` (watermarks stay comment-only), comment-only files, resource packs, simple packs, legacy packs, `archived/`.
- **Behavior to know:** a closed gate makes a function return 0, so `execute if function ...` callers (for example `macroengine:api/store/render`) see a failure. Cost: one score check per function call.
- **Verified:** `scripts/lint_datapacks.sh` (Mecha 0.101.0), `scripts/origin_watermarks.py --check`. The Gradle build was not run.
- **Not verified:** nothing was run in a Minecraft server. The re-run of the load entries after approval is untested in game (double initialization is possible for load code that is not idempotent).

## Datapacks: Gate 3 (per-player consent)

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

| Path | Change |
|---|---|
| `packs/{guikit-datapack,macroEngine-Datapack-v26.3,RTWrapper-v1.0.1}/data/<ns>/function/gate/*` | New: `consent_tick`, `consent_prompt`, `consent_grant`, `consent_reset`, `set/3_on`, `set/3_off`. `version` creates the `<ns>.consent` trigger and the `gate.3` default (on); `status` prints `gate.3`. |
| The same 2166 functions | Second gate line: `execute if entity @s[type=minecraft:player] unless entity @s[tag=<ns>.consented] unless score #<ns>.gate.3 vortaforge.gate matches 0 run return 0`. Functions that run as a player who has not consented do nothing. |
| `core/tick` of each pack | Calls `<ns>:gate/consent_tick` for every player without the `<ns>.consented` tag (prompt once, then `/trigger <ns>.consent set 1`). |

- **Defaults:** gate 3 on. Every player must agree once before pack functions run as them; server-context functions (tick, load) are not affected.
- **Limits:** consent is a tag plus a trigger, not authentication. Withdrawal is an operator function (`gate/consent_reset`), there is no player-side withdraw trigger yet. Datapack gates are removable plain text. Gate 4 (age declaration, a self-declaration and not verification) is not part of this PR.
- **Verified:** `scripts/lint_datapacks.sh` (Mecha 0.101.0), `scripts/origin_watermarks.py --check`. The Gradle build was not run.
- **Not verified:** nothing was run in a Minecraft server. The `as @a[tag=!...]` loop and the prompt flow are untested in game.

## Temporary archive notice (maintenance paused)

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

| Path | Change |
|---|---|
| `README.md` | New "Project status (maintenance paused)" section listing the packs below. |
| `packs/guikit-demo/README.md` | New file: archive notice; notes this pack has no `minecraft:load` of its own and hooks into `guikit-datapack`'s tags instead. |
| `packs/macroEngine-Datapack-v26.3/.../function/setup.mcfunction` | One-line `# [TEMPORARILY ARCHIVED] ...` comment prepended (`macroengine:setup`, the pack's `minecraft:load` target). |
| `packs/guikit-datapack/.../function/core/load.mcfunction` | Same comment prepended (`guikit:core/load`). |
| `packs/RTWrapper/datapack/RTWrapper-Datapack/.../function/core/load.mcfunction` | Same comment prepended (`rtwrapper:core/load`). |
| `packs/RTWrapper-1.21.1/.../function/core/load.mcfunction` | Same comment prepended (`rtwrapper:core/load`). |
| `packs/RTWrapper-v1.0.1/.../function/core/load.mcfunction` | Same comment prepended (`rtwrapper:core/load`). |

- **Scope:** comment-only edits to existing load/setup functions plus README additions. No logic, scoring, or gating behavior was changed.
- **Not covered:** `RTWrapper-1.21.1`'s separate `vortacraftmc:core/load` function was left untouched (out of the requested scope).
- **Verified:** nothing run; these are comment/doc-only changes.
- **Not verified:** nothing was run in a Minecraft server (not applicable — no executable logic changed).

## Archive notice reverted (unarchive)

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

The archive pass above was never finished: `archived/archive.json` was never
given entries for these packs, and `SECURITY.md` / `NOTICE.md` already stated
that nothing under `packs/` is archived. This pass completes the reversal.

| Path | Change |
|---|---|
| `README.md` | Removed the "Project status (maintenance paused)" section; added a note that `guikitfw` is the active successor to `guikit-datapack`. |
| `packs/macroEngine-Datapack-v26.3/.../function/setup.mcfunction` | Removed the `# [TEMPORARILY ARCHIVED] ...` comment line. |
| `packs/guikit-datapack/.../function/core/load.mcfunction` | Removed the comment line **and** the `tellraw`/`return 1` pair that had been blocking the function's own gate/registry logic from ever running. |
| `packs/RTWrapper/datapack/RTWrapper-Datapack/.../function/core/load.mcfunction` | Removed the comment line. |
| `packs/RTWrapper-v1.0.1/.../function/core/load.mcfunction` | Removed the comment line. |

- **`packs/guikit-demo/` and `packs/RTWrapper-1.21.1/`:** the previous pass above records edits to these two paths, but neither exists anywhere in this repository (`git log --all --diff-filter=A` for either returns nothing). Whatever those edits landed on, it was never part of this monorepo's `packs/` tree; no corresponding cleanup was possible or needed here. Other mentions of `guikit-demo` in this file's table above are kept as a historical record of that earlier, apparently unmerged work rather than edited to look consistent after the fact.
- **Scope:** reverts the comment-only edits above, plus the two extra lines in `guikit-datapack`'s load function noted above. No scoring, gating, or data-storage logic was changed beyond that.
- **Verified:** `scripts/check_archive.py` (passes: `1 project(s), 0 error(s)` — the single `archived/archive.json` entry is `runtoolkit/suite`, unaffected by this change).
- **Not verified:** `./gradlew checkArchive` was not run (no network access to `services.gradle.org` to fetch the Gradle distribution in this environment); nothing was run in a Minecraft server.

## 2026-11-05 - datapack retirement, kill switch, guard and blocklist

**AI involvement:** written by an Arena.ai agent at the request of the
maintainer. Not independently reviewed (Anti-Review).

**What changed:** the datapack programme was retired. Every pack, generator,
linter and test harness was moved with `git mv` into `archived/` (history
kept), the datapack Gradle logic was extracted verbatim from the root
`build.gradle` into `archived/build/*.gradle`, `archived/archive.json` was
rebuilt as schema v2 with a `reason` for every entry, and the enforcement was
added: `scripts/datapack_guard.py`, `scripts/datapacks_disable.py`,
`blocklist/blocklist.json`, `.githooks/`, the `datapack-guard` CI job and the
org-wide sync in `vortaforge/.github`.

**Verified (run here):** `python3 scripts/check_archive.py --strict` (28
entries, 0 errors), `scripts/datapacks_disable.py verify` (0 problems), the
Python suite (84 tests) and the Node website test, Groovy parse of
`build.gradle` / `settings.gradle` / `build-logic/project-tasks.gradle`, and a
real `gradle checkArchive checkDatapackSwitch verifyMod printArchiveList` run
plus `verifyProject writeProjectInventory` (mods and examples removed from a
throw-away copy) against Gradle 9.8.2 on JDK 21.

**Not verified:** `testGuiGenerator` (needs `pytest` and an editable
`guigenmc` install), a full `./gradlew ci` with the real `mods/` tree (Fabric
Loom needs network and a long build), the archived Ward runtime tests (a
Minecraft server must not be started), and any in-game behaviour. The
`vortaforge/.github` workflow was validated as YAML only; it has not run.

**Not a claim of quality:** the retirement reason records that the datapacks
lacked type safety, a security model, debugging and warnings and scored low in
review. Nothing here re-certifies the archived code.
