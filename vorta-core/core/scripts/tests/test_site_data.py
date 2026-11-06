#!/usr/bin/env python3
"""Tests for scripts/site/build_site_data.py.

These run without a network: the GitHub API is replaced by an in-process fake,
so the assertions are about the decisions (retry, fail-closed, filtering) rather
than about GitHub being reachable. The previous PHP version had no tests at all;
the only thing standing between a bad response and the deployed page was a human
reading the log.
"""

import importlib.util
import json
import os
import pathlib
import tempfile
import unittest
import urllib.error

ROOT = pathlib.Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "scripts" / "site" / "build_site_data.py"


def load_module():
    spec = importlib.util.spec_from_file_location("build_site_data", SCRIPT)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class ModFiltering(unittest.TestCase):
    def setUp(self):
        self.mod = load_module()

    def test_keeps_directories_only(self):
        items = [
            {"name": "afk-manager", "type": "dir"},
            {"name": "README.md", "type": "file"},
            {"name": "join-throttle", "type": "dir"},
        ]
        self.assertEqual(
            self.mod.mods_from_contents(items),
            [{"name": "afk-manager", "dir": "afk-manager"},
             {"name": "join-throttle", "dir": "join-throttle"}],
        )

    def test_excludes_scaffold_and_retired_mods(self):
        items = [{"name": n, "type": "dir"}
                 for n in ("TEMPLATE-MOD", "datapack-fixer", "rtwrapper-mod", "real-mod")]
        self.assertEqual([m["name"] for m in self.mod.mods_from_contents(items)], ["real-mod"])

    def test_rejects_names_that_could_escape_the_directory(self):
        items = [{"name": n, "type": "dir"} for n in ("../escape", "a/b", "ok-mod")]
        self.assertEqual([m["name"] for m in self.mod.mods_from_contents(items)], ["ok-mod"])

    def test_non_list_payload_is_not_an_error_but_is_empty(self):
        self.assertEqual(self.mod.mods_from_contents(None), [])
        self.assertEqual(self.mod.mods_from_contents({"message": "Not Found"}), [])


class FailClosed(unittest.TestCase):
    """A bad API response must abort the build, never publish a partial snapshot."""

    def setUp(self):
        self.mod = load_module()
        self.requests = []

    def _patch(self, handler):
        """Replace the single HTTP attempt, leaving github_get's retry loop real."""
        def fake(url, token):
            self.requests.append(url)
            return handler(url, token)
        self.mod._get_once = fake

    def test_retries_transient_failures_then_succeeds(self):
        calls = {"n": 0}

        def handler(url, token):
            calls["n"] += 1
            if calls["n"] < 3:
                raise self.mod._Retryable("HTTP 502")
            return 200, [{"name": "ok-mod", "type": "dir"}]

        self._patch(handler)
        self.mod.time.sleep = lambda _s: None
        out = os.path.join(tempfile.mkdtemp(), "site-data.json")
        self.assertEqual(self.mod.build(out, "vortaforge/core", None), 0)
        self.assertEqual(calls["n"], 3)

    def test_gives_up_after_three_attempts(self):
        self._patch(lambda url, token: (_ for _ in ()).throw(self.mod._Retryable("HTTP 500")))
        self.mod.time.sleep = lambda _s: None
        out = os.path.join(tempfile.mkdtemp(), "site-data.json")
        with self.assertRaises(self.mod.BuildError):
            self.mod.build(out, "vortaforge/core", None)
        self.assertEqual(len(self.requests), 3)
        self.assertFalse(os.path.exists(out), "a failed build must not write a snapshot")

    def test_empty_mod_list_refuses_to_publish(self):
        self._patch(lambda url, token: (200, []))
        out = os.path.join(tempfile.mkdtemp(), "site-data.json")
        with self.assertRaises(self.mod.BuildError):
            self.mod.build(out, "vortaforge/core", None)
        self.assertFalse(os.path.exists(out))

    def test_missing_mods_directory_is_fatal(self):
        self._patch(lambda url, token: (404, None))
        out = os.path.join(tempfile.mkdtemp(), "site-data.json")
        with self.assertRaises(self.mod.BuildError):
            self.mod.build(out, "vortaforge/core", None)

    def test_bad_repository_form_is_rejected_before_any_request(self):
        self._patch(lambda url, token: (200, []))
        out = os.path.join(tempfile.mkdtemp(), "site-data.json")
        with self.assertRaises(self.mod.BuildError):
            self.mod.build(out, "not-a-repo", None)
        self.assertEqual(self.requests, [], "no request should be made for a bad repo name")

    def test_non_https_url_is_refused(self):
        with self.assertRaises(self.mod.BuildError):
            self.mod._get_once("http://api.github.com/repos/x/y/contents/mods", None)


class Snapshot(unittest.TestCase):
    def setUp(self):
        self.mod = load_module()
        self.mod.github_get = lambda url, token: (
            200, [{"name": "afk-manager", "type": "dir"}])

    def test_snapshot_is_retired_pack_free_and_deterministic(self):
        out = os.path.join(tempfile.mkdtemp(), "nested", "site-data.json")
        self.assertEqual(self.mod.build(out, "vortaforge/core", "secret-token"), 0)
        data = json.loads(pathlib.Path(out).read_text(encoding="utf-8"))
        self.assertEqual(data["schemaVersion"], 1)
        self.assertTrue(data["datapacksRetired"])
        self.assertEqual(data["repository"], "vortaforge/core")
        self.assertEqual([m["name"] for m in data["mods"]], ["afk-manager"])
        # No pack/release data may come back into the snapshot.
        raw = pathlib.Path(out).read_text(encoding="utf-8")
        for gone in ("packs-latest", "releases/download", "releaseTag", "datapacks\""):
            self.assertNotIn(gone, raw)

    def test_token_is_never_written_into_the_snapshot(self):
        out = os.path.join(tempfile.mkdtemp(), "site-data.json")
        self.mod.build(out, "vortaforge/core", "ghp_SHOULD_NOT_APPEAR")
        self.assertNotIn("ghp_SHOULD_NOT_APPEAR", pathlib.Path(out).read_text(encoding="utf-8"))


class WorkflowWiring(unittest.TestCase):
    """pages.yml must run this script, and the PHP toolchain must be gone."""

    def setUp(self):
        self.workflow = (ROOT / ".github" / "workflows" / "pages.yml").read_text(encoding="utf-8")

    def test_workflow_calls_the_python_builder(self):
        self.assertIn("scripts/site/build_site_data.py", self.workflow)

    def test_no_php_toolchain_remains(self):
        self.assertNotIn("setup-php", self.workflow)
        self.assertNotIn("php ", self.workflow)
        self.assertNotIn("scripts/site/build_site_data.php", self.workflow)

    def test_the_php_script_is_archived_not_live(self):
        self.assertFalse(SCRIPT.with_suffix(".php").exists(),
                         "build_site_data.php should have been moved under archived/")


if __name__ == "__main__":
    unittest.main()


class ArchiveRegistry(unittest.TestCase):
    """The archived PHP script must be registered, with a successor that exists.

    check_archive.py treats an unreachable successor as a dangling pointer: the
    entry tells a reader "use that instead" and there is nothing at that path.
    """

    def setUp(self):
        import json
        registry = ROOT / "archived" / "archive.json"
        self.projects = json.loads(registry.read_text(encoding="utf-8"))["projects"]

    def test_archived_php_is_registered(self):
        entry = [p for p in self.projects if p.get("id") == "build-site-data-php"]
        self.assertEqual(len(entry), 1, "the archived PHP builder is not registered")
        self.assertEqual(entry[0]["original_path"], "scripts/site/build_site_data.php")
        self.assertTrue(entry[0].get("disarmed"))

    def test_every_non_datapack_successor_resolves(self):
        for project in self.projects:
            successor = project.get("successor")
            if not successor or project.get("kind") == "datapack":
                continue
            self.assertTrue(
                (ROOT / successor).exists(),
                f"{project['id']}: successor '{successor}' does not exist",
            )
