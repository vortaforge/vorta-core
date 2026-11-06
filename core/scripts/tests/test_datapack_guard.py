"""Regression tests for the datapack kill switch and its guard.

Everything here is offline: no git history is required, no network, no
Minecraft. The guard's wiring points (hooks, CI workflow, Gradle tasks) are
asserted too, because the previous datapack immutability lock in this
repository was removed for "enforcing nothing" - a policy that is not wired
into something that actually runs is documentation, not a guard.
"""
from __future__ import annotations

import json
import pathlib
import os
import re
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
GUARD = ROOT / "scripts" / "repo" / "datapack_guard.py"
SWITCH_TOOL = ROOT / "scripts" / "repo" / "datapacks_disable.py"
CHECK_ARCHIVE = ROOT / "scripts" / "repo" / "check_archive.py"
BLOCKLIST = ROOT / "blocklist" / "blocklist.json"

sys.path.insert(0, str(ROOT / "scripts" / "repo"))
import datapack_guard  # noqa: E402


def run(script: Path, *args: str, cwd: Path = ROOT) -> subprocess.CompletedProcess:
    return subprocess.run([sys.executable, str(script), *args], cwd=cwd,
                          capture_output=True, text=True, check=False, timeout=120)


def guard_with_changes(changes: str) -> subprocess.CompletedProcess:
    """Run the guard against a synthetic change list."""
    handle = tempfile.NamedTemporaryFile("w", suffix=".txt", delete=False, encoding="utf-8")
    try:
        handle.write(changes)
        handle.close()
        return run(GUARD, "--files-from", handle.name, "--protect", "--no-remote")
    finally:
        os.unlink(handle.name)


class DatapackClassification(unittest.TestCase):
    def test_mcfunction_and_pack_mcmeta_are_datapack_content(self):
        for path in ("packs/demo/data/demo/function/x.mcfunction",
                     "src/main/resources/data/demo/pack.mcmeta",
                     "whatever/pack.mcmeta"):
            with self.subTest(path=path):
                self.assertTrue(datapack_guard.is_datapack_path(path))

    def test_data_directories_for_every_registry_type_are_datapack_content(self):
        for directory in ("function", "functions", "advancement", "advancements",
                          "loot_table", "predicate", "item_modifier", "recipe",
                          "tags/function", "tags/functions", "worldgen"):
            with self.subTest(directory=directory):
                self.assertTrue(datapack_guard.is_datapack_path(
                    f"data/demo/{directory}/thing.json"))

    def test_java_and_docs_are_not_datapack_content(self):
        for path in ("mods/afk-manager/src/main/java/com/example/A.java",
                     "README.md", "archived/packs/DailyBonus/data/x/function/y.mcfunction",
                     "scripts/tests/fixtures/demo/pack.mcmeta"):
            with self.subTest(path=path):
                self.assertFalse(datapack_guard.is_datapack_path(path))


class GuardRules(unittest.TestCase):
    def test_new_pack_in_live_packs_tree_is_blocked(self):
        result = guard_with_changes("A\tpacks/NewPack/pack.mcmeta\n"
                                    "A\tpacks/NewPack/data/ns/function/run.mcfunction\n")
        self.assertEqual(result.returncode, 1, result.stdout)
        self.assertIn("live-packs-tree", result.stdout)

    def test_new_datapack_outside_packs_follows_the_switch(self):
        """Datapack content outside packs/ is gated by the switch, not blocked outright.

        The original assertion was "always blocked". That stopped being true once the
        programme was deliberately re-enabled, and it was asserting a policy rather
        than the rule: the rule is "block when the programme is off".
        """
        enabled = json.loads((ROOT / "datapacks.disabled.json").read_text(encoding="utf-8"))["enabled"]
        result = guard_with_changes("A\tmods/x/src/main/resources/data/foo/function/a.mcfunction\n")
        if enabled:
            self.assertEqual(result.returncode, 0,
                             "the switch is on, so new datapack content must be allowed: " + result.stdout)
        else:
            self.assertEqual(result.returncode, 1, result.stdout)
            self.assertIn("new-datapack", result.stdout)

    def test_archived_datapack_content_is_allowed(self):
        result = guard_with_changes("A\tarchived/packs/NewPack/data/ns/function/a.mcfunction\n")
        self.assertEqual(result.returncode, 0, result.stdout)
        self.assertNotIn("new-datapack", result.stdout)

    def test_test_fixture_datapack_is_allowed(self):
        result = guard_with_changes("A\tscripts/tests/fixtures/demo/pack.mcmeta\n")
        self.assertEqual(result.returncode, 0, result.stdout)

    def test_reviving_retired_tooling_is_blocked(self):
        for path in ("scripts/dpgen/builder.js", "scripts/ward_ci.sh",
                     "mods/datapack-blocker/build.gradle", ".github/workflows/ward.yml"):
            with self.subTest(path=path):
                result = guard_with_changes(f"A\t{path}\n")
                self.assertEqual(result.returncode, 1, result.stdout)
                self.assertIn("retired-tooling", result.stdout)

    def test_merge_manifest_cannot_reappear(self):
        result = guard_with_changes("A\tpacks/merge-manifest.json\n")
        self.assertEqual(result.returncode, 1, result.stdout)
        self.assertIn("merge-manifest", result.stdout)

    def test_deleting_a_pack_is_only_a_warning(self):
        result = guard_with_changes("D\tpacks/OldPack/pack.mcmeta\n")
        self.assertEqual(result.returncode, 0, result.stdout)
        self.assertIn("live-packs-removal", result.stdout)

    def test_unknown_change_status_is_a_usage_error_not_a_pass(self):
        handle = tempfile.NamedTemporaryFile("w", suffix=".txt", delete=False, encoding="utf-8")
        handle.write("Z\tpacks/x\n")
        handle.close()
        try:
            result = run(GUARD, "--files-from", handle.name, "--protect")
        finally:
            os.unlink(handle.name)
        self.assertEqual(result.returncode, 2, result.stdout + result.stderr)

    def test_normal_mod_change_passes(self):
        result = guard_with_changes("A\tmods/afk-manager/README.md\nM\tREADME.md\n")
        self.assertEqual(result.returncode, 0, result.stdout)


class Blocklist(unittest.TestCase):
    def setUp(self):
        self.blocklist = datapack_guard.Blocklist.load(BLOCKLIST)

    def test_blocklist_file_is_valid(self):
        data = json.loads(BLOCKLIST.read_text(encoding="utf-8"))
        self.assertEqual(data["schema_version"], 1)
        for entry in data["blocked"]:
            self.assertTrue(entry.get("reason"), "every blocked entry needs a reason")
            self.assertTrue(entry.get("added_on"))

    def test_known_datapack_developer_is_matched(self):
        hit = self.blocklist.matches("misode")
        self.assertIsNotNone(hit)
        self.assertEqual(hit["id"], "misode")

    def test_managed_accounts_are_exempt(self):
        for login in ("vortaforge", "vortaforge-maintenance", "github-actions"):
            with self.subTest(login=login):
                self.assertIsNone(self.blocklist.matches(login))

    def test_maintainers_are_exempt_and_their_pushes_are_not_blocked(self):
        """Regression: the blocklist once contained the maintainer's own accounts.

        `tickwarden` (the org owner, id 235496468) and `legends11` were listed
        under `known-datapack-authors`, which made CI refuse every push and pull
        request from the person who administers the organisation. They moved to
        `managed.accounts`; this test keeps them there.
        """
        data = json.loads(BLOCKLIST.read_text(encoding="utf-8"))
        managed = {str(x).lower() for x in data["managed"]["accounts"]}
        for login in ("tickwarden", "legends11"):
            with self.subTest(login=login):
                self.assertIn(login, managed,
                              f"{login} is a maintainer account and must stay in managed.accounts")
                self.assertIsNone(self.blocklist.matches(login),
                                  f"{login} must never match a blocked entry")

        # Every blocked login must also be absent from managed: the two lists
        # would otherwise contradict each other silently.
        blocked = {str(login).lower() for entry in data["blocked"]
                   for login in entry.get("logins", [])}
        self.assertFalse(blocked & managed,
                         f"these logins are both blocked and managed: {sorted(blocked & managed)}")

    def test_engineers_who_are_not_maintainers_are_not_listed_by_name(self):
        """Blocking someone needs a verified account, not a similar-looking login.

        `ironcrest` / `IronCrest-sudo` (ids 204314210 / 234182831) are different
        people from the maintainers and were never part of this project, so they
        must not appear anywhere in the blocklist. A similar login is not
        evidence of anything.
        """
        for login in ("IronCrest", "IronCrest-sudo", "ironcrest"):
            with self.subTest(login=login):
                self.assertIsNone(self.blocklist.matches(login))

    def test_blocked_entries_carry_verified_numeric_ids(self):
        """A login can be renamed; the numeric id cannot.

        Every account entry that names real people must pin `user_ids` so a
        rename cannot quietly lift the block.
        """
        data = json.loads(BLOCKLIST.read_text(encoding="utf-8"))
        for entry in data["blocked"]:
            if not entry.get("logins") or entry.get("match_bot_suffix") or entry.get("match_ai_accounts"):
                continue
            with self.subTest(entry=entry["id"]):
                self.assertTrue(entry.get("user_ids"),
                                f"'{entry['id']}' lists logins but no user_ids")
                self.assertEqual(len(entry["user_ids"]), len(entry["logins"]),
                                 f"'{entry['id']}': every login needs exactly one numeric id")

    def test_bot_suffix_rule(self):
        self.assertIsNotNone(self.blocklist.matches("some-helper[bot]"))
        self.assertIsNotNone(self.blocklist.matches("helpful-bot"))

    def test_ai_account_rule(self):
        self.assertIsNotNone(self.blocklist.matches("copilot-swe-agent"))
        self.assertIsNotNone(self.blocklist.matches("codex-agent"))

    def test_unrelated_account_is_not_matched(self):
        for login in ("octocat", "misode-fan-club"):
            with self.subTest(login=login):
                self.assertIsNone(self.blocklist.matches(login))

    def test_missing_blocklist_is_fail_closed(self):
        with self.assertRaises(datapack_guard.BlocklistError):
            datapack_guard.Blocklist.load(ROOT / "blocklist" / "does-not-exist.json")

    def test_pr_by_blocked_login_is_blocked(self):
        result = run(GUARD, "--pr", "--login", "misode", "--no-remote")
        self.assertEqual(result.returncode, 1, result.stdout)
        self.assertIn("blocklist-account", result.stdout)

    def test_pr_by_unblocked_login_passes(self):
        result = run(GUARD, "--pr", "--login", "octocat", "--no-remote")
        self.assertEqual(result.returncode, 0, result.stdout)


class KillSwitch(unittest.TestCase):
    """The switch, in whichever state the maintainer last put it.

    The original version asserted `enabled == False`, which made it a test of one
    particular decision rather than of the mechanism. It failed the moment the
    programme was deliberately re-enabled - correctly reporting a change, but with
    no way to tell "the switch was bypassed" from "the switch was used as designed".
    These tests check the properties that must hold in either state.
    """

    def test_switch_file_is_well_formed(self):
        data = json.loads((ROOT / "datapacks.disabled.json").read_text(encoding="utf-8"))
        self.assertIsInstance(data.get("enabled"), bool,
                              "enabled must be a real boolean; the string 'false' would read as truthy")
        self.assertTrue(data.get("reenable_token"), "the token must survive re-enabling")
        self.assertTrue(data.get("reason") or data.get("enabled_reason"),
                        "there must be a recorded reason for the current state")

    def test_disabled_requires_a_marker_and_enabled_does_not(self):
        enabled = json.loads((ROOT / "datapacks.disabled.json").read_text(encoding="utf-8"))["enabled"]
        marker = (ROOT / "archived" / "datapacks.disabled").is_file()
        if enabled:
            self.assertFalse(marker, "a disabled marker beside an enabled switch is contradictory")
        else:
            self.assertTrue(marker, "a disabled switch must carry its marker")

    def test_the_guard_agrees_with_the_switch(self):
        """The guard and the switch must not disagree about whether datapacks are live."""
        import sys
        sys.path.insert(0, str(ROOT / "scripts" / "repo"))
        import datapack_guard

        enabled = json.loads((ROOT / "datapacks.disabled.json").read_text(encoding="utf-8"))["enabled"]
        verdict = datapack_guard.rule_for_change("A", "some-new-pack/data/foo/function/bar.mcfunction")
        if enabled:
            self.assertIsNone(verdict,
                              "the switch says enabled but the guard still blocks new datapack content")
        else:
            self.assertIsNotNone(verdict, "the switch says disabled but the guard allowed the content")

    def test_a_missing_switch_counts_as_disabled(self):
        import sys
        import tempfile
        sys.path.insert(0, str(ROOT / "scripts" / "repo"))
        import datapack_guard

        with tempfile.TemporaryDirectory() as tmp:
            enabled, why = datapack_guard.datapacks_enabled(pathlib.Path(tmp))
        self.assertFalse(enabled, "an absent switch must never mean permitted")
        self.assertIn("missing", why)

    def test_verify_passes_on_this_tree(self):
        result = run(SWITCH_TOOL, "verify")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_enable_requires_the_token(self):
        result = run(SWITCH_TOOL, "enable", "--token", "wrong-token",
                     "--reason", "this should not be accepted at all")
        self.assertEqual(result.returncode, 2)

    def test_archive_registry_check_passes(self):
        result = run(CHECK_ARCHIVE, "--strict")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


class Wiring(unittest.TestCase):
    """A guard nobody runs is not a guard."""

    def read(self, *parts: str) -> str:
        return ROOT.joinpath(*parts).read_text(encoding="utf-8")

    def test_git_hooks_exist_and_call_the_guard(self):
        for hook, flag in (("pre-commit", "--staged"), ("pre-push", "--base")):
            with self.subTest(hook=hook):
                text = self.read("scripts/git/hooks", hook)
                self.assertIn("scripts/repo/datapack_guard.py", text)
                self.assertIn(flag, text)
                self.assertIn("exit 1", text)  # fail-closed when the guard is missing

    def test_called_workflow_never_widens_caller_permissions(self):
        """A reusable workflow may only narrow its caller's permissions.

        Regression: the guard job asked for `pull-requests: read` while the
        caller (build.yml) granted only `contents: read`. GitHub rejects that
        at parse time with a bare `startup_failure` and no annotation, so CI
        went red for a reason nobody could see.

        Deliberately parsed with a small text scanner instead of PyYAML: the
        CI image installs only the packages the repository actually needs, and
        a test that needs a missing import silently becomes an error, not a
        skip (this test originally did exactly that).
        """
        def permissions_block(text: str) -> dict[str, str]:
            """{scope: access} from the first top-level `permissions:` block."""
            lines = text.splitlines()
            try:
                start = lines.index("permissions:")
            except ValueError:
                return {}
            scopes: dict[str, str] = {}
            for line in lines[start + 1:]:
                if line and not line.startswith(" "):
                    break            # next top-level key
                stripped = line.strip()
                if not stripped or stripped.startswith("#"):
                    continue
                if ":" in stripped:
                    scope, _, access = stripped.partition(":")
                    scopes[scope.strip()] = access.strip()
            return scopes

        def job_permission_blocks(text: str) -> dict[str, dict[str, str]]:
            """{job_id: permissions} for every job that declares its own block."""
            lines = text.splitlines()
            jobs_at = lines.index("jobs:")
            result: dict[str, dict[str, str]] = {}
            current: str | None = None
            collecting: str | None = None
            scopes: dict[str, str] = {}
            for line in lines[jobs_at + 1:]:
                if re.match(r"^  [A-Za-z0-9_-]+:\s*$", line):
                    if current and scopes:
                        result[current] = scopes
                    current = line.strip().rstrip(":")
                    scopes = {}
                    collecting = None
                    continue
                if current is None:
                    continue
                if line.startswith("    ") and not line.startswith("      "):
                    key = line.strip()
                    collecting = key if key == "permissions:" else None
                    continue
                if collecting and line.startswith("      "):
                    stripped = line.strip()
                    if stripped and ":" in stripped and not stripped.startswith("#"):
                        scope, _, access = stripped.partition(":")
                        scopes[scope.strip()] = access.strip()
            if current and scopes:
                result[current] = scopes
            return result

        build_granted = permissions_block(self.read(".github", "workflows", "build.yml"))
        quality_top = permissions_block(self.read(".github", "workflows", "quality.yml"))
        self.assertTrue(build_granted, "build.yml must declare top-level permissions")
        self.assertTrue(quality_top, "quality.yml must declare top-level permissions")

        guards = job_permission_blocks(self.read(".github", "workflows", "quality.yml"))
        self.assertIn("datapack-guard", guards, "the guard job should pin its own permissions")

        for job_id, scopes in guards.items():
            widened_top = set(scopes) - set(quality_top)
            widened_caller = set(scopes) - set(build_granted)
            with self.subTest(job=job_id):
                self.assertFalse(
                    widened_top,
                    f"quality.yml job '{job_id}' requests {sorted(widened_top)}, which the "
                    "reusable workflow itself does not declare")
                self.assertFalse(
                    widened_caller,
                    f"quality.yml job '{job_id}' requests {sorted(widened_caller)}, which the "
                    "caller build.yml does not grant - GitHub fails with startup_failure")

    def test_ci_runs_the_guard_before_verification(self):
        quality = self.read(".github", "workflows", "quality.yml")
        self.assertIn("datapack-guard:", quality)
        self.assertIn("scripts/repo/datapack_guard.py", quality)
        self.assertIn("needs: [datapack-guard, verify]", quality)
        # guigenmc was archived with the datapack programme; it must not come back.
        self.assertNotIn("guigenmc-package", quality)
        self.assertNotIn("gui_generator", quality)
        # The guard job must appear before the verify job in the file, so a
        # reader sees it first and the gate wiring is obvious.
        self.assertLess(quality.index("datapack-guard:"), quality.index("\n  verify:"))
        self.assertIn("scripts/repo/datapacks_disable.py verify", quality)

    def test_gradle_wires_guard_and_switch(self):
        tasks = self.read("build-logic", "project-tasks.gradle")
        self.assertIn("tasks.register('guardArchives'", tasks)
        self.assertIn("scripts/repo/datapack_guard.py", tasks)
        self.assertIn("dependsOn 'guardArchives', 'checkDatapackSwitch', 'checkArchive'", tasks)
        root = self.read("build.gradle")
        self.assertIn("tasks.register('checkDatapackSwitch')", root)
        self.assertIn("scripts/repo/check_archive.py", root)

    def test_default_gradle_graph_has_no_pack_tasks(self):
        root = self.read("build.gradle")
        tasks = self.read("build-logic", "project-tasks.gradle")
        for gone in ("zipPacks", "mergeDatapacks", "checkPacks", "lintDatapacks",
                     "installDatapackLintDependencies", "testDpgen", "checkProvenance"):
            with self.subTest(task=gone):
                self.assertNotIn(f"tasks.register('{gone}'", root)
                self.assertNotIn(f"tasks.register('{gone}'", tasks)

    def test_weshould_not_have_a_ward_workflow(self):
        self.assertFalse((ROOT / ".github" / "workflows" / "ward.yml").exists())

    def test_readme_and_docs_point_at_the_switch(self):
        self.assertIn("datapacks.disabled.json", self.read("README.md"))
        self.assertTrue((ROOT / "docs" / "ARCHIVAL.md").is_file())



class ScopeAndEnforcement(unittest.TestCase):
    """`scope` and `enforcement` are declared in blocklist.json; they must be read.

    Regression (2026-11-05 audit): both fields were documented and both were
    ignored. A rule written for pull requests was therefore enforced on pushes
    too, and `enforcement: "review"` behaved exactly like `"block"`.
    """

    def setUp(self):
        self.tmp = tempfile.mkdtemp(prefix="bl-test-")
        self.addCleanup(shutil.rmtree, self.tmp, ignore_errors=True)

    def _load(self, entries):
        path = Path(self.tmp) / "blocklist.json"
        path.write_text(json.dumps({
            "schema_version": 1,
            "managed": {"owners": ["tickwarden"], "accounts": []},
            "policy": {},
            "blocked": entries,
        }), encoding="utf-8")
        return datapack_guard.Blocklist.load(path)

    def _run(self, blocklist, logins, scope, allow_review=False):
        report = datapack_guard.Report("test")
        datapack_guard.check_blocklist(report, blocklist, logins,
                                       scope=scope, allow_review=allow_review)
        return len(report.errors), len(report.findings) - len(report.errors)

    def test_scope_limits_a_rule_to_the_declared_actions(self):
        bl = self._load([{"id": "pr-only", "logins": ["Someone"],
                          "enforcement": "block", "scope": ["pull_request"],
                          "reason": "r"}])
        self.assertIsNotNone(bl.matches("Someone", scope="pull_request"))
        self.assertIsNone(bl.matches("Someone", scope="push"))

    def test_an_entry_without_scope_applies_everywhere(self):
        bl = self._load([{"id": "all", "logins": ["Someone"],
                          "enforcement": "block", "reason": "r"}])
        for scope in ("pull_request", "push", "org_membership", None):
            self.assertIsNotNone(bl.matches("Someone", scope=scope), scope)

    def test_unknown_scope_is_rejected_at_load(self):
        with self.assertRaises(datapack_guard.BlocklistError):
            self._load([{"id": "x", "logins": ["a"], "scope": ["telepathy"]}])

    def test_empty_scope_is_rejected_at_load(self):
        with self.assertRaises(datapack_guard.BlocklistError):
            self._load([{"id": "x", "logins": ["a"], "scope": []}])

    def test_unknown_enforcement_is_rejected_at_load(self):
        with self.assertRaises(datapack_guard.BlocklistError):
            self._load([{"id": "x", "logins": ["a"], "enforcement": "maybe"}])

    def test_review_entry_blocks_without_the_label(self):
        bl = self._load([{"id": "rev", "logins": ["Someone"],
                          "enforcement": "review", "reason": "r"}])
        errors, _ = self._run(bl, ["Someone"], "pull_request", allow_review=False)
        self.assertEqual(errors, 1)

    def test_review_entry_is_a_warning_with_the_label(self):
        bl = self._load([{"id": "rev", "logins": ["Someone"],
                          "enforcement": "review", "reason": "r"}])
        errors, warns = self._run(bl, ["Someone"], "pull_request", allow_review=True)
        self.assertEqual(errors, 0)
        self.assertEqual(warns, 1)

    def test_block_entry_ignores_the_label(self):
        # Documented: "that label does not override the account block itself."
        bl = self._load([{"id": "hard", "logins": ["Someone"],
                          "enforcement": "block", "reason": "r"}])
        errors, _ = self._run(bl, ["Someone"], "pull_request", allow_review=True)
        self.assertEqual(errors, 1, "the label must not clear an enforcement:block entry")

    def test_the_real_blocklist_survives_the_new_validation(self):
        bl = datapack_guard.Blocklist.load(ROOT / "blocklist" / "blocklist.json")
        self.assertTrue(bl.entries)
        for entry in bl.entries:
            self.assertIn(entry.get("enforcement", "block"),
                          datapack_guard.ENFORCEMENT_VALUES)



class NumericUserIdEnforcement(unittest.TestCase):
    """`user_ids` claims to be rename-proof; `--login-id` is what makes it so.

    Regression (2026-11-05 audit): the ids were in the data file but no code
    path ever passed one to the matcher, so a blocked account that renamed
    itself was checked only by its new login and slipped through.
    """

    def test_a_renamed_account_is_caught_by_its_id(self):
        result = run(GUARD, "--pr", "--login", "totally-new-name",
                     "--login-id", "17352009", "--no-remote")
        self.assertEqual(result.returncode, 1, result.stdout)
        self.assertIn("blocklist-user-id", result.stdout)

    def test_an_unrelated_id_is_not_blocked(self):
        result = run(GUARD, "--pr", "--login", "octocat",
                     "--login-id", "1", "--no-remote")
        self.assertEqual(result.returncode, 0, result.stdout)

    def test_a_non_numeric_id_is_rejected(self):
        result = run(GUARD, "--pr", "--login", "octocat",
                     "--login-id", "not-a-number", "--no-remote")
        self.assertEqual(result.returncode, 2, result.stdout + result.stderr)

    def test_ci_supplies_the_id(self):
        quality = (ROOT / ".github" / "workflows" / "quality.yml").read_text(encoding="utf-8")
        self.assertIn("PR_AUTHOR_ID", quality)
        self.assertIn("--login-id", quality)


class LabelCannotBypassContentChecks(unittest.TestCase):
    """The override label must not touch anything but review-scoped accounts."""

    def test_a_new_pack_is_blocked_even_with_the_label(self):
        tmp = tempfile.mkdtemp(prefix="label-test-")
        self.addCleanup(shutil.rmtree, tmp, ignore_errors=True)
        pack = Path(tmp) / "packs" / "Sneaky"
        (pack / "data" / "sneaky" / "function").mkdir(parents=True)
        (pack / "pack.mcmeta").write_text('{"pack":{"pack_format":121}}', encoding="utf-8")
        # 'A' = added; an added pack must be refused regardless of any label.
        report = datapack_guard.Report("test")
        datapack_guard.check_changes(report, [
            ("A", "packs/Sneaky/pack.mcmeta"),
            ("A", "packs/Sneaky/data/sneaky/function/a.mcfunction"),
        ])
        self.assertTrue(report.errors, "a new pack must be blocked before any label logic")


if __name__ == "__main__":
    unittest.main()


class AiAccountTokenMatching(unittest.TestCase):
    """A vendor name inside a longer handle is not an AI account.

    Audit 2026-11-06: `any(token in login for token in ("claude", "grok", ...))`
    blocked claudette, grokhalla, codexy, openaiden, gemini_rose and
    anthropic_fan. These are plausible human usernames. Blocking someone
    because their handle contains a vendor name is a false positive that costs
    a real person access to a project.
    """

    def setUp(self):
        import sys
        from pathlib import Path
        sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "repo"))
        import datapack_guard
        self.guard = datapack_guard
        self.bl = datapack_guard.Blocklist(
            entries=[{"id": "ai", "match_ai_accounts": True}],
            managed=set(), config={})

    def assert_blocked(self, login):
        self.assertIsNotNone(self.bl.matches(login=login),
                             f"{login} should match the AI account rule")

    def assert_allowed(self, login):
        self.assertIsNone(self.bl.matches(login=login),
                          f"{login} must not be blocked by a vendor substring")

    def test_partial_names_are_allowed(self):
        # A vendor name buried inside a longer word is not that vendor's account.
        for login in ("claudette", "grokhalla", "codexy", "openaiden",
                      "cLaudeLover", "realcopilot", "openair", "anthropos"):
            self.assert_allowed(login)

    def test_whole_tokens_are_blocked(self):
        # A standalone token still matches, including with common separators.
        # "gemini_rose" and "anthropic_fan" are blocked on purpose: the vendor
        # name stands alone as its own token there, which is exactly the
        # pattern this rule exists to catch.
        for login in ("chatgpt", "CLAUDE", "claude-bot", "use_claude",
                      "openai.dev", "grok", "copilot[bot]", "gemini_rose",
                      "anthropic_fan"):
            self.assert_blocked(login)

    def test_digit_suffix_is_still_a_fragment(self):
        # "gemini2" is one word, so the boundary rule treats it as a fragment.
        # Documented rather than silently surprising.
        self.assert_allowed("gemini2")

    def test_matching_ignores_case(self):
        for login in ("ChAtGpT", "OpenAI", "Anthropic"):
            self.assert_blocked(login)
