"""Offline regression tests for repository-level invariants.

Run with:  python3 -m pytest scripts/tests   (or: python3 -m unittest discover scripts/tests)

Nothing here starts, contacts or needs a Minecraft server.
"""
import os
import re
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
SCRIPT = os.path.join(ROOT, "scripts", "repo", "origin_watermarks.py")


def run_watermarks(script, *args):
    return subprocess.run(
        [sys.executable, script, *args], capture_output=True, text=True, check=False
    )


class RealTreeWatermarks(unittest.TestCase):
    def test_every_datapack_has_a_valid_watermark(self):
        # Regression: commit 5f2a74b deleted the macroEngine watermark, which
        # made the first CI step (--check) fail on main.
        result = run_watermarks(SCRIPT, "--check")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_watermark_checker_actually_scans_the_archived_packs(self):
        # 2026-11-05 regression: packs/README.md made the tool pick the (empty)
        # live tree and report "ok (0 watermark file(s) in 0 datapack(s))" -
        # a green result that checked nothing.
        result = run_watermarks(SCRIPT, "--report")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        # 11 datapacks + 1 resource pack, and 15 watermark files: the real
        # archived tree, not an empty scan that trivially passes.
        self.assertIn("11 datapack(s), 15 watermark file(s)", result.stdout)
        self.assertIn("pack(s) without one", result.stdout)


class WatermarkCheckerBehaviour(unittest.TestCase):
    """Negative controls on a throw-away copy of the layout the tool expects."""

    def setUp(self):
        self.tmp = tempfile.mkdtemp(prefix="wm-test-")
        self.addCleanup(shutil.rmtree, self.tmp, ignore_errors=True)
        os.makedirs(os.path.join(self.tmp, "scripts", "repo"))
        shutil.copy(SCRIPT, os.path.join(self.tmp, "scripts", "repo", "origin_watermarks.py"))
        open(os.path.join(self.tmp, "build.gradle"), "w").close()
        fn = os.path.join(self.tmp, "packs", "demo", "data", "demo", "function")
        os.makedirs(fn)
        with open(os.path.join(self.tmp, "packs", "demo", "pack.mcmeta"), "w") as fh:
            fh.write('{"pack": {"description": "x", "min_format": 1, "max_format": 1}}')
        with open(os.path.join(fn, "a.mcfunction"), "w") as fh:
            fh.write("say hi\n")
        self.script = os.path.join(self.tmp, "scripts", "repo", "origin_watermarks.py")
        self.mark = os.path.join(fn, "_vc_origin.mcfunction")

    def test_missing_watermark_fails_then_write_fixes_it(self):
        self.assertEqual(run_watermarks(self.script, "--check").returncode, 1)
        self.assertEqual(run_watermarks(self.script, "--write").returncode, 0)
        self.assertTrue(os.path.isfile(self.mark))
        self.assertEqual(run_watermarks(self.script, "--check").returncode, 0)

    def test_executable_line_in_watermark_is_rejected(self):
        run_watermarks(self.script, "--write")
        with open(self.mark, "a", encoding="utf-8") as fh:
            fh.write("say injected\n")
        result = run_watermarks(self.script, "--check")
        self.assertEqual(result.returncode, 1)
        self.assertIn("executable line", result.stdout + result.stderr)


class WorkflowPinning(unittest.TestCase):
    USES = re.compile(r"^\s*-?\s*uses:\s*(\S+)")
    SHA = re.compile(r"@[0-9a-f]{40}$")

    def test_all_actions_are_pinned_by_commit_sha(self):
        # The maintainer guide requires Actions pinned by commit SHA.
        wf_dir = os.path.join(ROOT, ".github", "workflows")
        unpinned = []
        for name in sorted(os.listdir(wf_dir)):
            if not name.endswith((".yml", ".yaml")):
                continue
            with open(os.path.join(wf_dir, name), encoding="utf-8") as fh:
                for no, line in enumerate(fh, 1):
                    m = self.USES.match(line)  # comment lines never match
                    if m and not m.group(1).startswith("./") and not self.SHA.search(m.group(1)):
                        unpinned.append(f"{name}:{no}: {m.group(1)}")
        self.assertEqual(unpinned, [], "actions not pinned by SHA")


class ReusableQualityWorkflowInvariants(unittest.TestCase):
    """Keep the CI trust boundary explicit when workflows are edited later."""

    def test_read_only_quality_and_artifact_only_publish_are_separated(self):
        workflows = os.path.join(ROOT, ".github", "workflows")
        with open(os.path.join(workflows, "build.yml"), encoding="utf-8") as fh:
            build = fh.read()
        with open(os.path.join(workflows, "quality.yml"), encoding="utf-8") as fh:
            quality = fh.read()

        self.assertIn("workflow_call:", quality)
        self.assertIn("contents: read", quality)
        # Packs are retired: the canonical graph is `ci`, and -PconfirmZip (the
        # old "yes, really zip the packs" flag) has no effect and must not be
        # advertised any more.
        self.assertIn("./gradlew ci --console=plain", quality)
        # -PconfirmZip may still appear in an explanatory comment (it says the
        # flag is no longer passed); it must not appear as an actual argument.
        self.assertNotIn("-PconfirmZip=yes", quality)
        self.assertIn("SHA256SUMS", quality)

        # Regression: after the packs went away the release path kept pointing
        # at *.zip - both the checksum step and the artifact upload. The
        # checksum step died on an empty glob (exit 1) and the upload would
        # have failed too, because it is declared if-no-files-found: error.
        self.assertIn("sha256sum -- *.jar", quality)
        self.assertNotIn("sha256sum -- *.zip", quality)
        self.assertIn("release-assets/*.jar", quality)
        self.assertNotIn("release-assets/*.zip", quality)

        # Regression: bash pattern substitution anchors at the end of a word, so
        # "${files[@]/%-sources.jar/}" strips every trailing ".jar" and leaves
        # extension-less paths that `cp` cannot find. That cost a red CI run.
        # The suffix filter must be an explicit case statement.
        self.assertNotIn('${files[@]/%-', quality)
        self.assertIn("*-sources.jar|*-javadoc.jar) continue", quality)
        self.assertNotIn("softprops/action-gh-release", quality)

        self.assertIn("uses: ./.github/workflows/quality.yml", build)
        self.assertIn("needs: quality", build)
        self.assertIn("contents: write", build)
        self.assertIn("actions/download-artifact@", build)
        self.assertIn("SHA256SUMS", build)
        self.assertNotIn("actions/checkout@", build)


class ReleaseAssetPreservationInvariants(unittest.TestCase):
    """Do not publish automatically until the no-deletion design is reviewed."""

    def test_publish_job_is_paused_and_does_not_delete_assets(self):
        path = os.path.join(ROOT, ".github", "workflows", "build.yml")
        with open(path, encoding="utf-8") as fh:
            build = fh.read()
        self.assertIn("\n  publish:\n", build)
        publish = build.split("\n  publish:\n", 1)[1]
        publish = re.split(r"(?m)^  [A-Za-z_][A-Za-z0-9_-]*:\s*$", publish, maxsplit=1)[0]
        self.assertRegex(publish, r"(?m)^    if: \$\{\{ false \}\}$")
        self.assertIn("          overwrite_files: false", publish)
        self.assertNotIn("gh release delete-asset", publish)
        self.assertIn("Retained older release assets", publish)

    def test_codeowners_sync_preserves_checkout_and_never_force_pushes(self):
        path = os.path.join(ROOT, ".github", "workflows", "codeowners-sync.yml")
        with open(path, encoding="utf-8") as fh:
            workflow = fh.read()
        self.assertIn("git worktree add --detach", workflow)
        self.assertNotIn("rm -f .github/CODEOWNERS", workflow)
        self.assertNotIn("git push --force", workflow)


class WardServerSafetyInvariants(unittest.TestCase):
    """The Ward job is the one place that starts a Minecraft server. These tests
    stop later edits from quietly loosening its isolation or dropping its warnings."""

    # 2026-11-05: the Ward kit and its workflow were archived; the warning now
    # lives in archived/README.md + scripts/README.md, and the guard tests point
    # at the archived copies so the isolation rules are still asserted.
    WARNED_FILES = ["docs/MAINTAINER_GUIDE.md", "README.md", "CONTRIBUTING.md", "NOTICE.md",
                    "SECURITY.md", "scripts/README.md", "archived/README.md",
                    "archived/tools/ward/ward.yml", "archived/tools/ward/ward_ci.sh",
                    "archived/tools/ward/ward_guard.py"]

    def read(self, rel):
        with open(os.path.join(ROOT, rel), encoding="utf-8") as fh:
            return fh.read()

    def test_every_documented_place_carries_the_warning(self):
        def warned(text):
            # one paragraph must carry both the word "warning" and a reference to Ward
            return any("warning" in para.lower() and "ward" in para.lower()
                       for para in re.split(r"\n\s*\n", text))
        missing = [f for f in self.WARNED_FILES if not warned(self.read(f))]
        self.assertEqual(missing, [])

    def test_workflow_stays_isolated(self):
        wf = self.read("archived/tools/ward/ward.yml")
        self.assertFalse(os.path.exists(os.path.join(ROOT, ".github/workflows/ward.yml")),
                         "the Ward workflow was archived and must not come back")
        runners = re.findall(r"(?m)^\s*runs-on:\s*(\S+)", wf)
        self.assertEqual(runners, ["ubuntu-latest"], "only GitHub-hosted runners")
        self.assertRegex(wf, r"(?m)^permissions:\n  contents: read$")
        self.assertNotIn("secrets.", wf)
        self.assertNotIn("environment:", wf)
        self.assertRegex(wf, r"(?s)Verify cleanup.*if: always\(\)")
        self.assertIn('"mcward==${MCWARD_VERSION}"', wf)
        self.assertRegex(wf, r'MCWARD_VERSION: "1\.4\.0"')

    def test_script_keeps_guards_verification_and_cleanup(self):
        sh = self.read("archived/tools/ward/ward_ci.sh")
        for needle in ("trap cleanup EXIT", "ward_guard.py", 'verify "$ENV_DIR"', '$GUARD seed "$ENV_DIR"',
                       'GITHUB_ACTIONS:-}" != "true"'):
            self.assertIn(needle, sh)
        # verification must happen before the tests start
        self.assertLess(sh.index('$GUARD verify "$ENV_DIR"'), sh.index("mcward test"))
        self.assertLess(sh.index('$GUARD seed "$ENV_DIR"'), sh.index("mcward start"))

    def test_locked_properties_cannot_be_loosened(self):
        sys.path.insert(0, os.path.join(ROOT, "archived", "tools", "ward"))
        import ward_guard
        locked = ward_guard.LOCKED_PROPERTIES
        self.assertEqual(locked["server-ip"], "127.0.0.1")
        for key in ("online-mode", "white-list", "enforce-whitelist"):
            self.assertEqual(locked[key], "true")
        for key in ("enable-rcon", "enable-query", "enable-status"):
            self.assertEqual(locked[key], "false")


class DailyBonusFirstClaim(unittest.TestCase):
    """Static guard for the unset-score defect, kept on the archived pack so a
    restore starts from a correct file. (Before 2026-11-05 the behavioural proof
    was the Ward test run in CI; Ward is archived with the packs.)"""

    def test_players_without_a_score_are_granted_before_the_comparison(self):
        base = os.path.join(ROOT, "archived", "packs", "DailyBonus", "data", "dailybonus")
        with open(os.path.join(base, "function", "tick.mcfunction"), encoding="utf-8") as fh:
            lines = [l.strip() for l in fh if l.strip() and not l.startswith("#")]
        unset = [i for i, l in enumerate(lines) if "unless score @s db_last_day matches" in l and l.endswith("function dailybonus:grant")]
        compare = [i for i, l in enumerate(lines) if "if score @s db_last_day < #day db_gameday" in l]
        self.assertTrue(unset and compare, lines)
        self.assertLess(unset[0], compare[0], "unset-score grant must run first to avoid a double grant")
        self.assertTrue(os.path.isfile(os.path.join(base, "test", "first_login_is_granted.mcfunction")))


class DownloadPageFallback(unittest.TestCase):
    """The static page must not advertise packs the build cannot produce.

    2026-11-05: the build produces no packs at all any more. The page now lists
    the archived projects as *not downloadable*, so the invariant is inverted:
    nothing in index.html may claim a .zip under packs-latest.
    """

    def test_no_pack_download_cards_remain(self):
        with open(os.path.join(ROOT, "index.html"), encoding="utf-8") as fh:
            html = fh.read()
        self.assertNotIn("FALLBACK_PACKS", html, "pack download fallback must be gone")
        self.assertRegex(html, r"retired|archived|disabled",
                         "the page must say the datapack programme is retired")

    def test_live_packs_tree_is_empty(self):
        packs_root = os.path.join(ROOT, "packs")
        allowed = {"README.md", ".gitkeep"}
        leftovers = sorted(n for n in os.listdir(packs_root)
                           if n not in allowed) if os.path.isdir(packs_root) else []
        self.assertEqual(leftovers, [])
        # The directory must still explain itself to anyone who opens it.
        self.assertTrue(os.path.isfile(os.path.join(packs_root, "README.md")))

    def test_offline_website_javascript(self):
        if not shutil.which("node"):
            self.fail("Node is required for the website behaviour regression test")
        result = subprocess.run(
            ["node", os.path.join(ROOT, "scripts", "tests", "site_behavior.test.mjs")],
            cwd=ROOT, capture_output=True, text=True, timeout=30, check=False,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


class ArchivedGradleLogic(unittest.TestCase):
    """The datapack Gradle logic moved to archived/build/*.gradle verbatim.

    These assertions used to read the root build.gradle; they now read the
    archived copy, so the safeguards inside that logic stay asserted even
    though nothing applies it.
    """

    def read_archived(self, *names):
        """Return one archived .gradle file, or all of them joined.

        The extraction split build.gradle by section, so helpers used by
        zipPacks live in pack-packaging-helpers.gradle while the task body lives
        in zip-packs.gradle. Reading them concatenated keeps these assertions
        meaningful without caring which file a line landed in.
        """
        directory = os.path.join(ROOT, "archived", "build")
        if not names:
            names = tuple(sorted(n for n in os.listdir(directory) if n.endswith(".gradle")))
        parts = []
        for name in names:
            with open(os.path.join(directory, name), encoding="utf-8") as fh:
                parts.append(fh.read())
        return "\n".join(parts)

    def test_root_build_has_no_datapack_packaging_tasks(self):
        with open(os.path.join(ROOT, "build.gradle"), encoding="utf-8") as fh:
            root = fh.read()
        for task in ("zipPacks", "mergeDatapacks", "checkPacks", "checkOriginWatermarks"):
            with self.subTest(task=task):
                self.assertNotIn(f"tasks.register('{task}')", root,
                                 f"{task} must stay archived, not re-registered")
        self.assertIn("apply from: \"$rootDir/build-logic/project-tasks.gradle\"", root)

    def test_generated_pack_root_outputs_are_excluded(self):
        script = self.read_archived()
        self.assertIn("parts.getName(0).toString()", script)
        self.assertGreaterEqual(script.count("isGeneratedPathEntry(srcDir, f)"), 2)
        self.assertIn("isGeneratedPathEntry(dir, f)", script)
        self.assertIn("contains generated or Ward test content", script)

    def test_gradle_archive_paths_exclude_ward_test_directories(self):
        script = self.read_archived()
        self.assertIn("parts.getName(0).toString() == 'data'", script)
        self.assertIn("parts.getName(2).toString() == 'test'", script)
        self.assertGreaterEqual(script.count("isWardTestPath(srcDir, f)"), 2)
        self.assertIn("isWardTestPath(dir, f)", script)
        pack_build = os.path.join(ROOT, "archived", "packs", "macroEngine-Datapack-v26.3", "build.gradle")
        with open(pack_build, encoding="utf-8") as fh:
            self.assertIn("exclude 'data/*/test/**'", fh.read())

    def test_merge_dry_run_returns_before_output_mutation(self):
        script = self.read_archived("merge-datapacks.gradle")
        merge = script.split("tasks.register('mergeDatapacks')", 1)[1]
        before_dry_return = merge.split('[mergeDatapacks] dry run OK:', 1)[0]
        self.assertNotIn("outDir.deleteDir()", before_dry_return)
        self.assertNotIn("outDir.mkdirs()", before_dry_return)
        self.assertIn("return", merge.split('[mergeDatapacks] dry run OK:', 1)[1].split("outDir.deleteDir()", 1)[0])


class MaintainerSafetyPolicy(unittest.TestCase):
    """Preserve project safeguards when the repository AI agent is retired."""

    def test_project_rules_remain_in_human_facing_guide(self):
        path = os.path.join(ROOT, "docs", "MAINTAINER_GUIDE.md")
        with open(path, encoding="utf-8") as fh:
            guide = fh.read()
        for rule in ("Never rewrite Git history", "force-push", "release assets",
                     "Never put a token, password or key", "Disclose AI assistance honestly",
                     "not independently reviewed (Anti-Review)",
                     "Do not run Minecraft-server tests locally", "Preserve runtime identifiers",
                     "third-party licence notices"):
            with self.subTest(rule=rule):
                self.assertIn(rule, guide)

    def test_retired_ai_automation_and_instruction_files_are_absent(self):
        for path in (".github/workflows/ai-agent.yml", ".github/scripts/ai-agent.js",
                     "AGENT.md", "CLAUDE.md"):
            with self.subTest(path=path):
                self.assertFalse(os.path.exists(os.path.join(ROOT, path)), path)


if __name__ == "__main__":
    unittest.main()
