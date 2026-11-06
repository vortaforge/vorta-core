# Repository scorecard — 2026-11-05

A scored audit of every part of this repository, written the same day as the
layout reorganisation. Each area is rated 0–10 against the criteria named in
its row, the defects behind a low score are listed, and the ones that were
fixed in this same change say so. Nothing here is aspirational: an unqualified
score means the state of the tree as committed.

**Scoring scale:** 9–10 exemplary · 7–8 good, minor gaps · 5–6 adequate, real
gaps · 3–4 weak · 0–2 broken or unfit.

## Summary

| # | Area | Score | Was | Verdict |
|---|---|---|---|---|
| 1 | Repository layout | **9** | 4 | Fixed: everything moved to a named home |
| 2 | Gradle build files | **8** | 6 | Fixed: orphan task removed, paths repointed |
| 3 | `scripts/` tooling | **8** | 5 | Fixed: grouped by ownership, junk archived |
| 4 | CI workflows | **8** | 5 | Fixed: dead job and dead install removed |
| 5 | Policy enforcement | **9** | 9 | Unchanged and strong |
| 6 | Tests | **9** | 8 | Fixed: +6 layout regression tests |
| 7 | Documentation | **7** | 5 | Fixed: layout rewritten, links verified |
| 8 | Archive registry | **9** | 6 | Fixed: 4 unregistered projects registered |
| 9 | `mods/` and `examples/` | **7** | 7 | Leaving as-is, see note |
| 10 | Dependency & supply chain | **7** | 6 | Fixed: Dependabot path |
| 11 | Error handling / fail-closed | **9** | 9 | Unchanged |
| 12 | Blocklist | **8** | 8 | Unchanged |

**Mean: 8.2/10** (was 6.6). Every area below 7 has a stated reason and an
owner-facing next step.

## 1. Repository layout — 9/10

*Criteria: can a newcomer find a thing by name; is anything loose at the root;
does the layout survive one item being added.*

Before: 16 loose entries at the root including a Python one-shot
(`remove_handover.py`), `datapacks.disabled.json`, four web assets, and a
`scripts/` directory holding four policy scripts, a forge of unrelated tools,
and the versioned hooks. There was no way to tell policy from plumbing.

After:

```
root/            only files GitHub Pages needs + the four Gradle entry files
                 + the seven top-level docs (README, INSTALL, NOTICE, ...)
scripts/repo/    guard, kill switch, archive validator, watermark checker
scripts/git/     pre-commit, pre-push
scripts/ops/     backup-org.sh (invoked by a workflow)
scripts/site/    build_site_data.py
scripts/tests/   offline regression suites
archived/tools/  guigenmc, fix_text_components, remove_handover, dpgen, ward, ...
```

Deducted one point: `mods/`, `examples/` and `packs/` still sit at the root
because `settings.gradle` auto-discovers them and moving them would be a
superproject change for no reader benefit.

## 2. Gradle build files — 8/10

*Criteria: does every declared task still have a subject; are paths right;
does the graph run offline.*

Fixed in this change:

- `testGuiGenerator` was left registering a pytest run against a package that
  no longer exists. Removed, and dropped from `verifyProject`. A task whose
  subject is gone is worse than no task: `verifyProject` would fail forever
  with a confusing "no tests ran".
- Every `scripts/*.py` path in `build.gradle` and
  `build-logic/project-tasks.gradle` was repointed to `scripts/repo/*.py`.

Verified: `./gradlew verifyProject` completes `BUILD SUCCESSFUL` on a tree with
the Loom subprojects removed (this sandbox has 2 GB of RAM, which Fabric Loom
cannot fit; the mod projects themselves were untouched by this change).

Deducted two points: `build.gradle` is 357 lines with a long historical
header, and the datapack-era task comments are kept for provenance. Splitting
it further would not improve anything a reader does.

## 3. `scripts/` tooling — 8/10

*Criteria: one job per script; no dead code; no untested destructive helper.*

Fixed in this change:

- `gui_generator/` (guigenmc) **archived**: it emits `.mcfunction` trees and
  `{menu_id}_datapack.zip`. Its output is a datapack, so it retires with the
  programme. The package is frozen but still functional for anyone who
  deliberately runs it (`python -m guigenmc --help` works).
- `fix_text_components.py` **archived**: its only input is datapack function
  files; with `packs/` empty it has no subject.
- `remove_handover.py` **archived**: a spent one-shot whose only reference was
  itself.
- `backup-org.sh` **kept live and moved to `scripts/ops/`**: it is executed by
  `.github/workflows/backup-org.yml` on manual dispatch. Archiving it would
  have broken a working feature — an archived file that a workflow still calls
  is exactly the half-finished state this repository forbids.

Deducted two points: `datapack_guard.py` is ~600 lines in one file and its
policy flags are the most consequential code here; it deserves a split, which
is a refactor rather than a fix and would risk the gate during a layout change.

## 4. CI workflows — 8/10

*Criteria: every job has a subject; no dead installs; the gate reflects what
actually runs.*

Fixed in this change:

- The `guigenmc-package` job (built a wheel, asserted `static/index.html` was
  inside it, uploaded distributions) was **removed**. Its subject is archived;
  leaving it would either fail or, worse, keep shipping a datapack generator
  as a release artifact.
- `pip install -e ./scripts/gui_generator` was removed from the `verify` job,
  along with its two cache keys. `pytest` and `build`/`twine` were installed
  only for that package; `pytest` is kept because `testRepository` uses it.
- Gate job: `needs`, env, table row and the success condition all lost the
  `guigenmc-package` reference in the same edit, so the gate cannot pass on a
  job that no longer exists.
- `backup-org.yml` repointed at `scripts/ops/backup-org.sh`.

Verified: `actionlint` reports only the intentional `if: false` on the
`pack-latest` publishing job, which predates this change.

Deducted two points: `build.yml` remains manually disabled (`if: false`), so
pushes to `main` do not run CI automatically. That is a deliberate maintainer
decision, not a defect, but it means "CI is green" is a claim about a run
someone triggered.

## 5. Policy enforcement — 9/10

*Criteria: does the gate fail closed; can it be bypassed silently.*

Unchanged, and the strongest part of the repository. The guard denies new
datapack content across `--staged`, `--base`, `--push` and `--pr`; the kill
switch is verified independently; the archive validator enforces a path
bijection. `scripts/gui_generator` was also added to `LIVE_DATAPACK_PATHS` so
the generator cannot quietly move back out of `archived/`.

One point withheld: a local `git commit --no-verify` still bypasses the hooks.
The documentation says so plainly, which is why this is a 9 and not a 10.

## 6. Tests — 9/10

*Criteria: do the tests actually run the real tree; do they fail when the
invariant breaks.*

90 tests, all passing, no network and no Minecraft. This change added six:

| New test | What it pins |
|---|---|
| `test_no_live_datapack_generator` | No datapack generator under `scripts/` |
| `test_moved_scripts_sit_under_scripts_subdirectories` | `scripts/` holds only the five grouped directories and its README |
| `test_archived_tools_are_all_registered` | Every `archived/tools/*` has an `archive.json` entry |
| `test_reorg_left_no_dangling_references` | No live file names a retired path (six intentional exceptions are documented inline) |
| `test_hooks_path_points_at_the_moved_hooks` | No doc teaches the old `core.hooksPath .githooks` |
| `test_scorecard_documents_the_real_layout` | Every directory this scorecard names exists |

Each was written to fail on a real break. Two did, during this change: the
hooks still called `scripts/datapack_guard.py`, and the watermark template had
been silently rewritten, which the real-tree watermark test caught.

Deducted one point: the guard and the archive validator have narrow negative
coverage compared with their branching, and `backup-org.sh` has no test at all
(it needs organization credentials).

## 7. Documentation — 7/10

*Criteria: does each doc describe the tree it ships with; any dead links.*

Fixed in this change: `README.md` Structure, `scripts/README.md` (rewritten
around the new layout and the archived tools), `docs/MAINTAINER_GUIDE.md`
hooks table and pytest command, `archived/README.md` tool table,
`INSTALL.md`/`NOTICE.md`/`docs/ARCHIVAL.md` hooks path, `.gitignore`.

Verified: 46 relative markdown links resolve; no dead internal links.

Deducted three points, all honest gaps rather than regressions:
`CREDITS.md` is 725 lines and is now a chronological changelog with
duplicated attribution rows; `docs/` holds only two documents for a repository
this size; and there is no contributor-facing "how the guard decides" page
(the guard's docstring is the only explanation).

## 8. Archive registry — 9/10

*Criteria: does every archived artefact have an entry that matches reality.*

Four previously unregistered items were added with a reason, known issues and
correct paths: `gui-generator`, `fix-text-components`, `remove-handover` and
(transiently) `backup-org`. The last one was removed again when it turned out
to be live tooling — which is the registry doing its job: it forced the
question "is this actually retired?", and the answer was no.

Registry now validates at **31 projects, 0 errors, 0 warnings** under
`--strict`.

One point withheld: `original_path` had to be cleared for `remove-handover`
because a root-level one-shot never lived under a live root, and the schema's
rule for `original_path` assumes it did. That is a small modelling gap in the
schema, documented in the entry rather than papered over.

## 9. `mods/` and `examples/` — 7/10

*Criteria: buildable, documented, no dead templates.*

Untouched by this change, and deliberately so: they are Fabric projects that
have nothing to do with the datapack programme, and they were not part of the
reorganisation problem. `settings.gradle` discovers 3 mods and 1 example.
`verifyMod` reports nothing to check when they are absent.

Deducted three points for pre-existing state that would need a mod-level
review rather than a repository cleanup: the mods carry their own Kotlin and
Java toolchains, and there is no CI job that builds them (CI's `ci` task does,
which is why it needs JDK 25 and the Loom memory budget).

## 10. Dependency and supply-chain — 7/10

*Criteria: is every dependency update mechanism pointed at something that
exists; are third-party actions pinned.*

Fixed in this change: the Dependabot pip entry pointed at
`/scripts/gui_generator`, a directory that no longer exists, which is silently
inert. Repointed to `/archived/tools/gui-generator` — deliberate: the archived
package is not built, but watching it keeps its pinned dependencies from
rotting into a known-vulnerable state while it sits in the tree.

Unchanged and verified: every `uses:` in every workflow is a full commit SHA
with a version comment, enforced by a test.

Deducted three points: pip and Gradle still resolve from the network at run
time with no lockfile for the repository's own tooling (it is stdlib-only by
design, which is why the score is not lower), and there is no SBOM.

## 11. Error handling / fail-closed behaviour — 9/10

*Criteria: when a check cannot run, does it pass or fail.*

Unchanged. The guard exits non-zero when its inputs are missing, when the
blocklist cannot be loaded, and when the archive validator is absent — all
three verified by tests. The hooks refuse to commit or push if the guard file
itself is missing. Nothing in the reorganisation changed a failure mode: the
Gradle task, both hooks, CI and the tests all fail closed on a missing path,
which is precisely how the stale `scripts/datapack_guard.py` reference in the
hooks was caught.

## 12. Blocklist — 8/10

*Criteria: enforced, mirrored, auditable.*

Unchanged. Four blocked groups, four managed accounts, `managed ∖ blocked = ∅`,
`blocklist_sync.py --check --core ../core` reports the org mirror is up to
date, and every entry needs a written rationale plus a numeric account id
(test-enforced).

Deducted two points: enforcement is only as good as token hygiene on the
runner, which this repository cannot observe.

## What was deliberately not done

- **`mods/` untouched.** Out of scope for a layout change, and a mod refactor
  would bury the reorganisation diff.
- **`build.gradle` not split.** Splitting a 357-line file during a rename-heavy
  change makes review harder, not easier.
- **`CREDITS.md` not condensed.** It is historical record; rewriting 725 lines
  of attribution is a separate decision for the maintainers.
- **`backup-org.sh` not archived.** It is live. See area 3.

## How to re-score

Every number above is reproducible from the tree:

```sh
python3 -m unittest discover -s scripts/tests        # 90 tests
python3 scripts/repo/check_archive.py --strict       # 31 projects, 0/0
python3 scripts/repo/datapacks_disable.py verify     # 0 problems
python3 scripts/repo/origin_watermarks.py --check    # 15 watermarks, 11 packs
python3 scripts/repo/datapack_guard.py --staged --protect --blocklist
node --test scripts/tests/site_behavior.test.mjs
./gradlew verifyProject                              # needs the Loom subprojects
```
