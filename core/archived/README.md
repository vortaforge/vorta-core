# archived/

> [!CAUTION]
> **The archive is frozen.** Nothing under `archived/` runs, builds or ships. Bringing a project back is not a revert: it counts as a **new project proposal** and goes through that review.

Everything in this directory is **frozen, reference-only and hard-disarmed**.
Nothing under `archived/` is built, merged, zipped, linted, tested or executed
by the Gradle build or by CI. `settings.gradle` does not scan this directory.

**Status: the datapack programme in `vortaforge/core` is retired (2026-11-05).**
`packs/` is empty, `archived/archive.json` lists every retired project with
`"disarmed": true`, and `datapacks.disabled.json` is the switch that keeps it
that way. New datapack content is refused in pre-commit, pre-push and CI by
`scripts/repo/datapack_guard.py`.

## Why

Datapacks, as shipped here, had:

* **no type safety** — every value that crosses a function call, a storage
  read, a scoreboard comparison or a macro expansion is an untyped string that
  nothing checks at load time or at run time;
* **no security model** — stored-string command execution runs at
  `function-permission-level` with no authentication boundary, and each pack
  needed its own opt-in gate (`docs/dynamic-command-gate.md`, archived) that a
  player could not verify;
* **no debugging** — no trace, breakpoint, log or state inspection beyond
  hand-written `tellraw`;
* **no warnings** — malformed references and wrong pack formats failed silently
  or at run time instead of at build time;
* and it **scored low in review**.

It was bad enough that it would have been better had it not shipped at all. The
maintainer gave up on it after hitting real problems as a plain player using
a datapack **with no client mod installed**, and the same class of problems
kept showing up in pull requests.

## Layout

| Path | Contents | Registry ids |
|---|---|---|
| `archived/packs/` | The 12 retired packs (11 datapacks + 1 resource pack), moved verbatim with their git history. | `dailybonus` … `vf-macro` |
| `archived/tools/` | Datapack generators, linters and test harnesses: `dpgen/`, `gui-generator/` (`guigenmc`), `datapack-lint/`, `build-release/`, `ward/` (with its workflow), `datapack-blocker/` (Fabric mod), plus the spent one-shots `fix_text_components.py` and `remove_handover.py`. | `dpgen`, `gui-generator`, `datapack-lint`, `build-release`, `ward`, `datapack-blocker-mod`, `fix-text-components`, `remove-handover` |
| `archived/build/` | The datapack Gradle logic that used to live in the root `build.gradle`, extracted **verbatim, as separate files** (see `probe.lock` for the exact source line ranges). | `build-*` |
| `archived/examples/` | `template-datapack/` — the example pack template. | `template-datapack` |
| `archived/docs/` | `dynamic-command-gate.md`, `static-analysis-findings-2026-10-30.md`. | `dynamic-command-gate-doc`, `static-analysis-findings` |
| `archived/merge-manifest.json` | The merge manifest that used to drive `mergeDatapacks`. Kept next to the packs it merged. | — |
| `archived/archive.json` | The registry (schema: `archive.schema.json`, `schema_version` 2). | — |
| `archived/datapacks.disabled` | Human-readable marker for the kill switch. | — |

### `archived/build/` — the extracted Gradle logic

| File | Was `build.gradle` section |
|---|---|
| `origin-watermark-helpers.gradle` | 3 — `findOriginWatermarks`, `findPackDirs`, `findMissingWatermarks`, `showOriginWatermarks`, `cleanOriginWatermarks`, `checkOriginWatermarks` |
| `pack-packaging-helpers.gradle` | 3b — `copyDirRecursive`, `zipDirectory`, sensitive/generated/Ward path filters |
| `zip-packs.gradle` | 4 — `zipPacks` |
| `pack-validation-helpers.gradle` | 5 — `vc*` helpers (namespace, pack format, function reference resolution) |
| `check-packs.gradle` | 5 — `checkPacks`, `printPackList`, `printPackFormats` |
| `merge-datapacks.gradle` | 6 — `mergeDatapacks` |

These were split out on 2026-11-05 so the live `build.gradle` contains no
datapack code at all. They are **not applied**; they are the exact record of
how the packs were validated, merged and packaged, and the starting point if
the decision is ever reversed. The copies are byte-identical to the original
sections (only a provenance header was prepended), and
`scripts/tests/test_repo_invariants.py` asserts the important parts (watermark
guards, Ward-test exclusions, dry-run safety) against these files.

## Validation

```bash
python3 scripts/repo/check_archive.py            # authoritative registry check
./gradlew checkArchive                      # same, through Gradle
./gradlew checkDatapackSwitch               # kill switch engaged?
python3 scripts/repo/datapacks_disable.py verify # switch + marker + registry + empty packs/
./gradlew printArchiveList                  # human-readable list
```

`check_archive.py` fails when:

* the schema version is not 2, a required field is missing, an unknown field is
  present, an enum/date/id is invalid, or `reason` is missing;
* an entry is not `"disarmed": true` (a missing `disarmed` is an error, so a v1
  registry cannot silently re-enable code);
* a `kind: "datapack"` entry does not set `"is_datapack": true`;
* `path` escapes the repository, does not exist, or does not start with
  `archived/`;
* a `.github/` path or a workflow file would live under `archived/`;
* an `original_path` still exists (the move was incomplete);
* a directory under `archived/packs/` or `archived/tools/` has no registry
  entry, or a registry path has no directory (bijection);
* `packs/` is not empty, `packs/merge-manifest.json` exists, or any retired
  tool path is live again;
* `settings.gradle` scans `archived/`.

`-PcheckArchiveStrict=true` / `--strict` turns warnings (e.g. a missing
successor) into failures.

## The kill switch

| Piece | Path | Meaning |
|---|---|---|
| Switch | `datapacks.disabled.json` | `"enabled": false`. Missing or unreadable counts as disabled. |
| Marker | `archived/datapacks.disabled` | Human-readable explanation. |
| Token | `datapacks.disabled.json#reenable_token` | Required to re-enable. |
| CLI | `scripts/repo/datapacks_disable.py` | `status`, `disable`, `enable`, `verify`. |
| Guard | `scripts/repo/datapack_guard.py` | Blocks new datapack content anywhere live. |

Re-enabling is deliberate:

```bash
python3 scripts/repo/datapacks_disable.py enable \
    --token VORTAFORGE-DATAPACKS-2026-11-05-DISARMED \
    --reason "why this is being re-enabled, in one sentence"
```

That flips the switch but does **not** move packs back. A restore still needs
each project moved out of `archived/`, its registry entry removed, its
`original_path` cleared, and the `archived/build/*.gradle` sections re-applied
by hand (they are kept for exactly that reason). Treat it as a new project
proposal, with the review the old one never had.

## Rules

- **Do not delete anything here.** The registry, the packs and the extracted
  Gradle logic are the record of a decision.
- **No new content.** A PR that adds or edits anything under `archived/` is
  expected to change `archive.json` in the same commit; CI reviews the diff
  against the registry.
- **Archived projects are never built or shipped.** If a build task starts
  looking at `archived/`, that is a bug in the build.
- **Licences and provenance stay intact**: each project's `LICENSE`, the
  `_vc_origin.mcfunction` watermarks, `NOTICE.md` and `THIRD_PARTY_LICENSES.md`.
- **A workflow must never live under `archived/`** — GitHub runs whatever is in
  `.github/workflows/`, so `archived/tools/ward/ward.yml` is inert by
  construction. `check_archive.py` enforces this.

## ⚠️ Warning — a Minecraft server is started in exactly one place, and it is archived

Warning: `archived/tools/ward/` (formerly `scripts/ward_ci.sh`, `scripts/ward_guard.py`
and `.github/workflows/ward.yml`) is the only thing in this repository that ever
started a Minecraft server, via the Ward (mcward) harness. It is now inactive:
the workflow is not under `.github/workflows/` any more, so GitHub will not run
it. **Never run `ward_ci.sh` on a developer machine, a production host or next
to a real world.** Nothing else in the repository starts, connects to or tests
against a Minecraft server.
