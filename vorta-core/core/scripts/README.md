# scripts/

> [!WARNING]
> **Every script here is treated as lower trust by default** (`NOTICE.md`). Read it before running it, and never run quality tooling with privileged credentials.

Helper tooling for this monorepo. `NOTICE.md` treats everything here as
**lower trust by default**: inspect code and dependencies before use, and
avoid running quality tooling with privileged credentials.

## Layout

Grouped by what each script owns, so a reader can tell policy from plumbing:

| Directory | Holds |
|---|---|
| [`repo/`](repo/) | Repository policy checks: the guard, the kill switch, the archive validator, the watermark checker. |
| [`git/hooks/`](git/hooks/) | Versioned `pre-commit` / `pre-push` hooks (`git config core.hooksPath scripts/git/hooks`). |
| [`ops/`](ops/) | Operational helpers a workflow invokes, e.g. `backup-org.sh` (run by `.github/workflows/backup-org.yml`). |
| [`site/`](site/) | `build_site_data.py`, the data-snapshot builder for the landing page (Python, like every other script here; the PHP original is archived). |
| [`tests/`](tests/) | Offline regression tests for everything above. No network, no Minecraft. |

## Repository tooling

| Script or test | Role when explicitly run |
|---|---|
| [`repo/datapack_guard.py`](repo/datapack_guard.py) | **The gate.** Fail-closed policy: no new datapack content, no revived archived tooling, no blocklisted accounts, kill switch engaged, registry consistent. Runs in `pre-commit`, `pre-push`, CI (job `datapack-guard`) and Gradle (`guardArchives`). |
| [`repo/datapacks_disable.py`](repo/datapacks_disable.py) | The kill-switch CLI: `status`, `disable`, `enable --token ... --reason ...`, `verify`. |
| [`repo/check_archive.py`](repo/check_archive.py) | Validates `archived/archive.json` (schema v2): shape, hard-disable flags, path bijection, no workflows under `archived/`, empty `packs/`. Stdlib only. |
| [`tests/`](tests/) | Python regression tests: guard/blocklist/switch behaviour, archive invariants, repository layout, workflow-action pinning, credential patterns, credential-shape scan, the static site's retirement notices, plus offline tests for the archived Ward guard and release builder. |
| [`repo/origin_watermarks.py`](repo/origin_watermarks.py) | Checks or generates the no-op provenance watermarks. `--check` does not modify sources. Kept for the archived packs; no build step invokes it any more. |
| [`ops/backup-org.sh`](ops/backup-org.sh) | Organization-backup tool driven by `.github/workflows/backup-org.yml` (manual dispatch only). It handles privileged organization data: read it before running it, and prefer the workflow, which passes its arguments through environment variables instead of prompts. |

`verifyProject` wires the offline regression suites and the policy checks into
the Gradle graph. The workflow configuration describes that graph; it does not
itself mean GitHub workflows are enabled or have run. Publishing remains
paused pending human validation.

### Archived with the datapack programme

`repo/` contains no datapack tooling: the guard blocks `scripts/gui_generator`
and the other retired paths from coming back. Everything that emitted or
rewrote datapack output is under [`archived/tools/`](../archived/tools/) and
registered in `archived/archive.json`:

| Archived tool | What it did | Why it is there |
|---|---|---|
| `gui-generator/` (`guigenmc`) | Turned a JSON menu spec into a GUI datapack (`.mcfunction` + `data/` + a zip). | Its output is a datapack. |
| `fix_text_components.py` | Rewrote legacy text-component JSON inside pack function files. | Only had datapack files as input. |
| `remove_handover.py` | Deleted `HANDOVER*.md` and stripped one README block during the retirement. | Spent one-shot; nothing it targets exists. |

## Audit retirement and coverage gaps

`audit_repo.py` and `audit_full.py` were removed in the 2026-10-30 cleanup;
`auditRepository` is no longer a Gradle task. The independent regression
checks in `tests/test_repository_safeguards.py` retain selected safeguards:
pack metadata and layout, load/tick tag shape and required function targets,
static merged-function references and merge-manifest checks, invalid indexed
NBT path patterns, common credential shapes, and license consistency. Other
existing tests check workflow action pinning, ZIP contents, archive rules and
provenance. Negative fixtures exercise several of these checks.

These are **not a full replacement** for the old audits. In particular:

- Required tag targets are resolved across the repository's pack tree, not
  proven available in every combination of installed packs. Function macros,
  generated or dynamic calls, and all cross-pack runtime effects cannot be
  fully resolved statically.
- Credential matching covers selected common token/key forms in small working-
  tree text files; it skips symlinks, binary files and files over 2 MB. It is not secret
  scanning, does not prove the absence of credentials and does not revoke any.
- The removed scripts' broad Markdown-link, workflow/Gradle reference,
  commit-message, stale-branch and other general repository audit checks are
  not all replicated. Run specialized checks and human review where needed.
- No replacement queries organization/repository settings, branch protection,
  2FA, billing, Dependabot status or other remote GitHub state. No automatic
  fix or remote-branch deletion functionality was carried forward.
- Static tooling cannot establish the safety of dynamic commands or prove
  game behaviour, permissions, compatibility across every supported version,
  or that release assets are suitable for publishing.

## Self-contained tools

None live here any more. Each self-contained tool had its own README, licence
and dependency manifest and was versioned independently of the repository
tooling above; the last one, `guigenmc`, was archived on 2026-11-05 because it
emits datapack output.

`guigenmc` emitted datapack output, so it was a generator all along: its output
could never be checked into `packs/` (the guard blocks it). It now lives in
[`archived/tools/gui-generator/`](../archived/tools/gui-generator/) with the
programme it served, registered in `archived/archive.json`. `archived/tools/dpgen`
was retired earlier for the same reason.

Dependabot watches `archived/tools/gui-generator` for pip updates so the
archived package does not rot into a vulnerable state while it sits unbuilt;
dependency proposals require human review. Nothing builds or installs it.

## Removed from here

`apply_audit_fixes.py`, `fix_macro_lines.py`, `datapack_risk_scan.py` and
`datapack_lock/check_lock.py` were deleted on 2026-10-08. The first two were
one-off fixers from a single audit session whose changes were already
committed; `check_lock.py` implemented a lock that nothing invoked, against a
workflow that never existed. `dp-depman/` and the two audit scripts were
retired in the 2026-10-30 cleanup. Git history preserves their provenance.

## Ward test server (archived)

> **Warning: this path used to start a Minecraft server.** The Ward harness
> (`ward_ci.sh`, `ward_guard.py` and `.github/workflows/ward.yml`) was archived
> on 2026-11-05 into `archived/tools/ward/`. The workflow file is no longer
> under `.github/workflows/`, so GitHub does not run it, and nothing in the live
> repository starts, connects to or tests against a Minecraft server. Never run
> the archived script on a developer machine, a production host or next to a
> real world.

- `archived/tools/ward/ward_ci.sh` orchestrated install, lockdown, tests and
  cleanup; it refused to run outside GitHub Actions.
- `archived/tools/ward/ward_guard.py` seeded locked `server.properties`,
  checked listeners and discovered packs with Ward tests.
- `tests/test_ward_guard.py` still runs in the normal suite against the
  archived module, so the isolation rules stay asserted if it is ever restored.
