#!/usr/bin/env python3
"""Regression tests for scripts/blocklist_sync.py.

Stdlib only: this repository has no Python dependencies, and CI installs none.
Every test here is a real regression from the 2026-11-05 audit - see the
docstring of each test for the behaviour it pins.
"""
from __future__ import annotations

import json
import subprocess
import sys
import shutil
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SYNC = ROOT / "scripts" / "blocklist_sync.py"
sys.path.insert(0, str(ROOT / "scripts"))

import blocklist_sync  # noqa: E402


def source_blocklist() -> dict:
    """A minimal stand-in for vortaforge/core's blocklist/blocklist.json."""
    return {
        "schema_version": 1,
        "updated_on": "2026-11-05",
        "$comment": "source copy",
        "managed": {"owners": ["tickwarden"], "accounts": ["github-actions"]},
        "policy": {"profile_scan": True, "profile_tokens": ["datapack"],
                   "profile_exempt_tokens": ["not a datapack author"]},
        "blocked": [
            {"id": "zeta", "logins": ["Zeta"], "user_ids": [2],
             "enforcement": "block", "reason": "second"},
            {"id": "alpha", "logins": ["Alpha"], "user_ids": [1],
             "enforcement": "block", "reason": "first"},
        ],
    }


class Determinism(unittest.TestCase):
    """The mirror must be a pure function of the source."""

    def test_generated_on_comes_from_the_source_not_today(self):
        # Regression: `generated_on = date.today()` made the mirror depend on
        # WHEN it was rendered. A pristine mirror checked the next day did not
        # equal a fresh render, so --check reported drift against an unchanged
        # source and the daily workflow committed a no-op every day.
        out = blocklist_sync.normalise(source_blocklist())
        self.assertEqual(out["generated_on"], "2026-11-05")

    def test_generated_on_is_stable_across_calls(self):
        a = blocklist_sync.normalise(source_blocklist())
        b = blocklist_sync.normalise(source_blocklist())
        self.assertEqual(a["generated_on"], b["generated_on"])

    def test_normalise_does_not_mutate_the_source(self):
        src = source_blocklist()
        before = json.dumps(src, sort_keys=True)
        blocklist_sync.normalise(src)
        self.assertEqual(json.dumps(src, sort_keys=True), before)

    def test_entries_are_sorted_for_stable_output(self):
        out = blocklist_sync.normalise(source_blocklist())
        self.assertEqual([e["id"] for e in out["blocked"]], ["alpha", "zeta"])


class BothFilesAreChecked(unittest.TestCase):
    """`generated/` is the copy other tooling reads; it must be verified too."""

    def setUp(self):
        # The CLI resolves TARGET/GENERATED relative to its own module file, so
        # running it as a subprocess would touch the real tree. Call mirror()
        # in-process instead, against a throw-away tree.
        self.tmp = Path(tempfile.mkdtemp(prefix="sync-test-"))
        self.addCleanup(shutil.rmtree, self.tmp, ignore_errors=True)
        self.target = self.tmp / "blocklist" / "blocklist.json"
        self.generated = self.tmp / "generated" / "blocklist.json"
        self.core = self.tmp / "core"
        (self.core / "blocklist").mkdir(parents=True)
        (self.core / "blocklist" / "blocklist.json").write_text(
            json.dumps(source_blocklist()), encoding="utf-8")
        self._saved = (blocklist_sync.TARGET, blocklist_sync.GENERATED)
        blocklist_sync.TARGET = self.target
        blocklist_sync.GENERATED = self.generated
        self.addCleanup(self._restore)

    def _restore(self):
        blocklist_sync.TARGET, blocklist_sync.GENERATED = self._saved

    def _run(self, write: bool) -> int:
        return blocklist_sync.mirror(self.core, fetch=False, write=write)

    def test_write_then_check_is_clean(self):
        self.assertEqual(self._run(write=True), 0)
        self.assertEqual(self._run(write=False), 0)

    def test_a_corrupt_generated_copy_is_drift(self):
        # Regression: only `blocklist/blocklist.json` was compared, so a
        # corrupted `generated/blocklist.json` passed --check.
        self.assertEqual(self._run(write=True), 0)
        self.generated.write_text('{"corrupted": true}\n', encoding="utf-8")
        self.assertEqual(self._run(write=False), 1)

    def test_a_missing_generated_copy_is_drift(self):
        self.assertEqual(self._run(write=True), 0)
        self.generated.unlink()
        self.assertEqual(self._run(write=False), 1)

    def test_write_repairs_a_corrupt_generated_copy(self):
        self.assertEqual(self._run(write=True), 0)
        self.generated.write_text("{}", encoding="utf-8")
        self.assertEqual(self._run(write=True), 0)
        self.assertEqual(self.target.read_text(), self.generated.read_text())

    def test_check_reports_without_writing(self):
        self.assertEqual(self._run(write=False), 1)
        self.assertFalse(self.target.exists(), "--check must not write")
        self.assertFalse(self.generated.exists(), "--check must not write")


class ProfileScanFields(unittest.TestCase):
    """The documented scan fields must be the ones actually read."""

    def test_blog_is_scanned(self):
        # Regression: `blog` is documented and fetched but was missing from the
        # haystack, so a token that appeared only in the profile's website link
        # was reported clean.
        policy = {"profile_tokens": ["datapack"]}
        profile = {"login": "someone", "bio": "", "company": "", "name": "",
                   "blog": "https://someone.example/datapack-stuff"}
        self.assertEqual(blocklist_sync.scan(profile, policy)["verdict"], "hit")

    def test_documented_fields_all_match(self):
        policy = {"profile_tokens": ["datapack"]}
        for field in ("bio", "company", "name", "blog"):
            profile = {"login": "x", "bio": "", "company": "", "name": "", "blog": ""}
            profile[field] = "i write datapack code"
            self.assertEqual(blocklist_sync.scan(profile, policy)["verdict"], "hit",
                             f"{field} is not scanned")

    def test_exempt_phrase_still_wins(self):
        policy = {"profile_tokens": ["datapack"],
                  "profile_exempt_tokens": ["not a datapack author"]}
        profile = {"login": "x", "name": "Datapack Maintainer", "company": "", "bio": "",
                   "blog": "https://example.test"}
        self.assertEqual(blocklist_sync.scan(profile, policy)["verdict"], "hit")
        profile["bio"] = "not a datapack author"
        self.assertEqual(blocklist_sync.scan(profile, policy)["verdict"], "exempt")

    def test_clean_profile(self):
        policy = {"profile_tokens": ["datapack"]}
        profile = {"login": "x", "name": "Java dev", "company": "Acme",
                   "bio": "fabric mods", "blog": "https://example.test"}
        self.assertEqual(blocklist_sync.scan(profile, policy)["verdict"], "clean")


class NoUnnecessaryCommits(unittest.TestCase):
    """The daily workflow must only commit when the source really changed."""

    def test_rendering_twice_produces_identical_bytes(self):
        src = source_blocklist()
        a = json.dumps(blocklist_sync.normalise(src), indent=2, ensure_ascii=False)
        b = json.dumps(blocklist_sync.normalise(src), indent=2, ensure_ascii=False)
        self.assertEqual(a, b)

    def test_a_source_change_does_show_up_as_drift(self):
        # The determinism fix must not make the mirror blind to real changes.
        src = source_blocklist()
        first = json.dumps(blocklist_sync.normalise(src), indent=2, ensure_ascii=False)
        src["blocked"].append({"id": "zeta2", "logins": ["Zeta2"], "reason": "new"})
        second = json.dumps(blocklist_sync.normalise(src), indent=2, ensure_ascii=False)
        self.assertNotEqual(first, second)

    def test_a_new_source_date_is_reflected(self):
        src = source_blocklist()
        first = blocklist_sync.normalise(src)["generated_on"]
        src["updated_on"] = "2026-12-01"
        self.assertNotEqual(first, blocklist_sync.normalise(src)["generated_on"])


if __name__ == "__main__":
    unittest.main()


class WorkflowFailsClosed(unittest.TestCase):
    """A scan that checked nobody must never report success.

    Regression (2026-11-05 audit): `gh pr list ... || true` plus a `no accounts
    to scan; exit 0` did exactly that. An API error produced an empty list, the
    scan then found nothing to look at, and the job went green - reporting a
    clean organisation when it had checked zero accounts.
    """

    def setUp(self):
        import pathlib
        raw = pathlib.Path(
            ".github/workflows/datapack-blocklist-sync.yml").read_text(encoding="utf-8")
        self.workflow = raw
        # Join backslash continuations so a command can be matched as one unit.
        self.logical = raw.replace("\\\n", " ").splitlines()

    def test_gh_list_failures_are_not_discarded(self):
        for call in ("gh pr list", "gh issue list"):
            lines = [l for l in self.logical
                     if call in l and "--json author" in l]
            self.assertTrue(lines, f"{call} author listing not found")
            for line in lines:
                self.assertNotIn("|| true", line,
                                 f"{call} still discards its exit status")

    def test_an_empty_account_list_is_an_error(self):
        self.assertNotRegex(
            self.workflow, r"no accounts to scan\W*\n\s*exit 0",
            "an empty account list is still reported as a successful scan")
        self.assertIn("cannot report success", self.workflow)


class ProfileScanClaims(unittest.TestCase):
    """The scan must not tell an account it blocked them when it did not.

    Audit 2026-11-06: the policy says profile_scan_action=review, nothing writes
    a hit into the blocklist, and the guard reads only the blocklist file -- yet
    the issue text told the account "your pull requests are refused
    (fail-closed)". A user reading that would reasonably believe they were
    blocked. They were not.

    A claim like that is worse than silence: it is a false statement about
    enforcement, made to the person it affects.
    """

    def setUp(self):
        import pathlib
        self.raw = pathlib.Path(
            ".github/workflows/datapack-blocklist-sync.yml").read_text(encoding="utf-8")

    def test_issue_body_does_not_promise_a_block(self):
        for phrase in ("pull requests are refused",
                       "pull requests from that account are refused",
                       "fail-closed) by the guard"):
            self.assertNotIn(
                phrase, self.raw,
                f"the issue text still promises blocking it does not do: {phrase!r}")

    def test_issue_body_says_it_does_not_block(self):
        self.assertIn("does not block anyone", self.raw)
        self.assertIn("request for human review", self.raw)

    def test_policy_action_is_review_not_block(self):
        import json, pathlib
        policy = json.loads(pathlib.Path("blocklist/blocklist.json").read_text(encoding="utf-8"))
        self.assertEqual(policy["policy"]["profile_scan_action"], "review",
                         "policy and the issue text must agree")

    def test_no_automatic_membership_enforcement_is_claimed(self):
        # Only affirmative claims matter. The correction reads "no automatic
        # organisation-wide enforcement", so a blunt substring check would fail
        # on its own disclaimer; this looks at the two words either side.
        import re
        for match in re.finditer(r"(\w+\s+)?(\w+\s+)?(organisation-wide|org-wide)\s+enforcement",
                                 self.raw):
            preceding = " ".join(w for w in match.group(1, 2) if w).lower()
            self.assertTrue(
                "no" in preceding or "not" in preceding,
                f"affirmative org-wide enforcement claim: {...!r}".replace("...", match.group(0)))
        self.assertIn("no automatic organisation-wide enforcement", self.raw)
