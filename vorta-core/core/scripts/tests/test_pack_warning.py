#!/usr/bin/env python3
"""Tests for scripts/repo/pack_warning.py.

The property these protect is narrow and specific: an archived pack must tell a
player it is archived, in syntax the pack's own Minecraft version can parse.

The second half matters as much as the first. `click_event` does not exist
before Minecraft 1.21.5 (data pack format 71), and `value` was renamed to `url`
in the same release. A warning written with the wrong field name for the pack's
target is a command error on the exact version the pack was built for -- worse
than no warning, because it fails at run time in front of a player.
"""

import importlib.util
import json
import pathlib
import re
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "scripts" / "repo" / "pack_warning.py"
PACKS = ROOT / "archived" / "packs"
DOCS_URL = "https://vortaforge.github.io/docs/docs/warnings.html"


def load():
    spec = importlib.util.spec_from_file_location("pack_warning", SCRIPT)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class SyntaxMatchesTargetVersion(unittest.TestCase):
    """The whole point: pick the field names the pack's version understands."""

    def setUp(self):
        self.mod = load()

    def _component(self, fmt: int):
        body = self.mod.warning_body(PACKS / "DailyBonus", fmt, "TestPack")
        line = [l for l in body.splitlines() if l.startswith("tellraw")]
        self.assertTrue(line, "no tellraw line generated")
        return json.loads(line[0].split("tellraw @a ", 1)[1])

    def test_modern_pack_uses_click_event_and_url(self):
        for fmt in (71, 101, 107, 121):
            comp = self._component(fmt)
            clicky = [c for c in comp if "click_event" in c][0]
            self.assertEqual(clicky["click_event"]["action"], "open_url")
            self.assertEqual(clicky["click_event"]["url"], DOCS_URL)
            self.assertNotIn("value", clicky["click_event"],
                             "1.21.5+ renamed value to url; the old key is a command error")
            self.assertNotIn("clickEvent", json.dumps(comp),
                             "the pre-1.21.5 field name must not appear in a 1.21.5+ pack")

    def test_old_pack_uses_clickEvent_and_value(self):
        for fmt in (6, 10, 12, 26, 41, 61, 70):
            comp = self._component(fmt)
            clicky = [c for c in comp if "clickEvent" in c][0]
            self.assertEqual(clicky["clickEvent"]["action"], "open_url")
            self.assertEqual(clicky["clickEvent"]["value"], DOCS_URL)
            self.assertNotIn("url", clicky["clickEvent"],
                             "pre-1.21.5 used value; url is not parsed there")
            self.assertNotIn("click_event", json.dumps(comp))

    def test_the_boundary_is_exactly_71(self):
        self.assertNotIn("click_event", json.dumps(self._component(70)))
        self.assertIn("click_event", json.dumps(self._component(71)))

    def test_old_pack_also_spells_out_the_url(self):
        # A pre-1.21.5 client may refuse to open a link; the plain text fallback
        # means the reader can still reach the docs by hand.
        body = self.mod.warning_body(PACKS / "DailyBonus", 12, "OldPack")
        self.assertGreaterEqual(body.count(DOCS_URL), 2,
                                "old-format warning should show the URL as text as well")

    def test_modern_pack_does_not_clutter_with_a_bare_url(self):
        # The one occurrence outside the tellraw line is the source comment that
        # records where the link points. The player-visible text must not also
        # spell it out -- the link is clickable there.
        body = self.mod.warning_body(PACKS / "DailyBonus", 121, "NewPack")
        tellraw = [l for l in body.splitlines() if l.startswith("tellraw")][0]
        self.assertEqual(tellraw.count(DOCS_URL), 1)


class CheckIsIdempotentAndBites(unittest.TestCase):
    """--check must pass on the real tree and fail when a warning is removed."""

    def test_check_passes_on_the_repository(self):
        self.assertEqual(self.run_check(), 0)

    def test_check_fails_when_a_warning_file_is_removed(self):
        import tempfile, shutil
        with tempfile.TemporaryDirectory() as tmp:
            copy = pathlib.Path(tmp) / "packs"
            shutil.copytree(PACKS, copy)
            victim = next(copy.rglob("archive_warning.mcfunction"))
            victim.unlink()
            self.assertEqual(self.run_check(packs_dir=copy), 1,
                             "removing a warning must fail the check")

    def test_check_fails_when_the_tag_entry_is_removed(self):
        import tempfile, shutil
        with tempfile.TemporaryDirectory() as tmp:
            copy = pathlib.Path(tmp) / "packs"
            shutil.copytree(PACKS, copy)
            # Drop the warning from every load tag: the function still exists,
            # but nothing calls it, which is the failure that looks green.
            for tag in copy.rglob("minecraft/tags/function*/load.json"):
                data = json.loads(tag.read_text())
                data["values"] = [v for v in data.get("values", [])
                                  if "archive_warning" not in v]
                tag.write_text(json.dumps(data))
            self.assertEqual(self.run_check(packs_dir=copy), 1)

    @staticmethod
    def run_check(packs_dir=None):
        import contextlib, importlib.util, io
        spec = importlib.util.spec_from_file_location("pw_under_test", SCRIPT)
        mod = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(mod)
        if packs_dir is not None:
            mod.PACKS_DIR = pathlib.Path(packs_dir)
        # main() prints a per-pack report; swallow it so the test output stays
        # readable, but keep the exit code -- that is the assertion.
        with contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
            return mod.main(["--check"])


class RealPacksAreCorrect(unittest.TestCase):
    """Check the generated functions actually in the tree, not just the generator."""

    def setUp(self):
        self.files = sorted(PACKS.rglob("archive_warning.mcfunction"))

    def test_every_pack_with_a_load_path_has_a_warning(self):
        self.assertGreaterEqual(len(self.files), 8, "expected at least 8 warned packs")

    def test_every_generated_component_is_valid_json_with_a_real_url(self):
        for f in self.files:
            line = [l for l in f.read_text(encoding="utf-8").splitlines()
                    if l.startswith("tellraw")]
            self.assertTrue(line, f"{f}: no tellraw line")
            comp = json.loads(line[0].split("tellraw @a ", 1)[1])
            self.assertIsInstance(comp, list)
            clicky = [c for c in comp if "click_event" in c or "clickEvent" in c]
            self.assertTrue(clicky, f"{f}: no click target")
            event = clicky[0].get("click_event") or clicky[0].get("clickEvent")
            self.assertEqual(event["action"], "open_url")
            url = event.get("url") or event.get("value")
            self.assertTrue(url.startswith("https://"),
                            f"{f}: 1.21.5+ only parses http(s) URIs, got {url!r}")
            self.assertEqual(url, DOCS_URL)

    def test_no_warning_uses_the_wrong_field_for_its_pack(self):
        """A 1.21.5+ pack must not contain clickEvent, and vice versa."""
        mod = load()
        for f in self.files:
            root = f
            while root.parent != PACKS and not (root / "pack.mcmeta").is_file():
                root = root.parent
            if not (root / "pack.mcmeta").is_file():
                continue
            fmt, _ = mod.pack_format(root)
            text = f.read_text(encoding="utf-8")
            if fmt >= mod.CLICK_EVENT_MIN_FORMAT:
                self.assertNotIn('"clickEvent"', text,
                                 f"{f.name} in {root.name} (fmt {fmt}) uses the pre-1.21.5 field")
            else:
                self.assertNotIn('"click_event"', text,
                                 f"{f.name} in {root.name} (fmt {fmt}) uses 1.21.5+ only syntax")

    def test_every_tag_entry_resolves_to_a_real_function(self):
        """A wired tag pointing at a missing function is a silent failure.

        Minecraft logs nothing useful for an unknown function in a load tag: the
        pack simply runs nothing, and the warning the whole change exists for
        never appears. Check the resolution, not just the presence of the file.
        """
        checked = 0
        for tag in PACKS.rglob("minecraft/tags/function*/load.json"):
            for value in json.loads(tag.read_text(encoding="utf-8")).get("values", []):
                if "archive_warning" not in str(value):
                    continue
                namespace, name = str(value).split(":", 1)
                # The tag lives at <root>/data/minecraft/tags/<dir>/load.json, so
                # the pack root is four levels up. (Off by one here silently
                # pointed at data/ and made every entry look dangling.)
                root = tag.parents[4]
                matches = list((root / "data" / namespace).rglob(f"{name.rsplit('/', 1)[-1]}.mcfunction"))
                self.assertTrue(matches, f"{tag}: {value} does not resolve to a function")
                checked += 1
        self.assertGreaterEqual(checked, 8, "expected at least 8 wired warnings")

    def test_no_warning_is_written_into_the_reserved_minecraft_namespace(self):
        # data/minecraft/function/ is engine territory, not a pack namespace, and
        # a warning addressed as minecraft:archive_warning is a bug.
        for f in self.files:
            parts = f.parts
            idx = parts.index("data")
            self.assertNotEqual(parts[idx + 1], "minecraft",
                                f"{f} is in the reserved minecraft namespace")

    def test_warnings_are_marked_as_generated(self):
        for f in self.files:
            self.assertIn("vortaforge:archive_warning", f.read_text(encoding="utf-8"))

    def test_a_warning_is_not_claimed_to_be_a_gate(self):
        for f in self.files:
            text = f.read_text(encoding="utf-8")
            self.assertIn("A warning is not a gate", text,
                          f"{f}: the warning must not imply it disables the pack")


if __name__ == "__main__":
    unittest.main()
