"""Offline tests for archived/tools/build-release/build_release.py.

Archived with the datapack programme on 2026-11-05 (archived/archive.json, id
"build-release"). Run with:

    python3 -m unittest discover archived/tools/build-release

Nothing here starts, contacts or needs a Minecraft server.
"""
import os
import shutil
import sys
import tempfile
import unittest
import zipfile

sys.path.insert(0, os.path.dirname(__file__))
import build_release  # noqa: E402


def write(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as fh:
        fh.write(text)


class MinifyTests(unittest.TestCase):
    def test_drops_comments_and_blank_lines(self):
        src = "# header\n\nsay one\n   \n# tail comment\nsay two   \n"
        self.assertEqual(build_release.minify_mcfunction(src), "say one\nsay two\n")

    def test_hash_inside_command_text_is_kept(self):
        # A '#' that is not at the start of a line is not a comment: it can be
        # a fake-player name or text inside a JSON component.
        src = 'scoreboard players set #foo demo.obj 1\ntellraw @s {"text":"#tag"}\n'
        self.assertEqual(build_release.minify_mcfunction(src), src)

    def test_macro_lines_survive(self):
        src = "# macro: $(cmd)\n$$(cmd)\n"
        self.assertEqual(build_release.minify_mcfunction(src), "$$(cmd)\n")

    def test_comment_only_file_becomes_empty(self):
        self.assertEqual(build_release.minify_mcfunction("# only a comment\n\n"), "")

    def test_idempotent(self):
        src = "# c\n\n  say padded  \n$execute as @s run $(cmd)\n"
        once = build_release.minify_mcfunction(src)
        self.assertEqual(build_release.minify_mcfunction(once), once)


class BuildTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.mkdtemp(prefix="build-release-")
        self.addCleanup(shutil.rmtree, self.tmp, ignore_errors=True)
        self.packs = os.path.join(self.tmp, "packs")
        demo = os.path.join(self.packs, "demo")
        write(os.path.join(demo, "pack.mcmeta"),
              '{"pack": {"description": "demo", "min_format": 1, "max_format": 1}}')
        write(os.path.join(demo, "data", "demo", "function", "run.mcfunction"),
              "# documented\n\n$$(cmd)\n")
        write(os.path.join(demo, "data", "demo", "function", "_vc_origin.mcfunction"),
              "# provenance stays\n")
        write(os.path.join(demo, "data", "demo", "test", "ward_only.mcfunction"),
              "assert score #x demo.obj matches 1\n")
        write(os.path.join(demo, "LICENSE"), "demo license\n")
        write(os.path.join(demo, "THIRD_PARTY_LICENSES.md"), "third-party notice\n")

    def test_zip_contents(self):
        out = os.path.join(self.tmp, "out")
        built = build_release.build_all(self.packs, out)
        self.assertEqual(sorted(built), ["demo"])
        with zipfile.ZipFile(built["demo"]) as zf:
            names = zf.namelist()
            # Ward tests are not vanilla and must not ship in a release pack.
            self.assertFalse(any("/test/" in n for n in names), names)
            self.assertIn("pack.mcmeta", names)
            self.assertEqual(zf.read("LICENSE"), b"demo license\n")
            self.assertEqual(zf.read("THIRD_PARTY_LICENSES.md"), b"third-party notice\n")
            self.assertEqual(
                zf.read("data/demo/function/run.mcfunction").decode("utf-8"),
                "$$(cmd)\n")
            # The provenance watermark is the one comment that ships verbatim.
            self.assertEqual(
                zf.read("data/demo/function/_vc_origin.mcfunction").decode("utf-8"),
                "# provenance stays\n")
        self.assertTrue(os.path.isfile(os.path.join(out, "SHA256SUMS.txt")))

    def test_real_macroengine_notice_is_in_the_individual_zip(self):
        repo = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
        source = os.path.join(repo, "archived", "packs", "macroEngine-Datapack-v26.3")
        archive = os.path.join(self.tmp, "macro.zip")
        build_release.build_pack_zip(source, archive)
        with zipfile.ZipFile(archive) as zf:
            for name in ("LICENSE", "THIRD_PARTY_LICENSES.md"):
                with open(os.path.join(source, name), "rb") as original:
                    self.assertEqual(zf.read(name), original.read())
            self.assertIn(b"Copyright (c) 2022 Michael Weatherby", zf.read("THIRD_PARTY_LICENSES.md"))

    def test_dynamic_inventory_finds_whole_command_macro(self):
        out = os.path.join(self.tmp, "out")
        build_release.build_all(self.packs, out)
        import json
        with open(os.path.join(out, "dynamic-surfaces.json"), encoding="utf-8") as fh:
            inventory = json.load(fh)
        kinds = [hit["kind"] for hit in inventory["packs"]["demo"]]
        self.assertEqual(kinds, ["whole_command_macro"])

    def test_build_is_deterministic(self):
        out_a = os.path.join(self.tmp, "a")
        out_b = os.path.join(self.tmp, "b")
        zip_a = build_release.build_all(self.packs, out_a)["demo"]
        zip_b = build_release.build_all(self.packs, out_b)["demo"]
        self.assertEqual(build_release.sha256_of(zip_a),
                         build_release.sha256_of(zip_b))

    def test_check_mode_passes(self):
        self.assertEqual(build_release.check_deterministic(self.packs), [])

    def test_unknown_pack_is_an_error(self):
        with self.assertRaises(SystemExit):
            build_release.build_all(self.packs, os.path.join(self.tmp, "o"),
                                    only=["no-such-pack"])


if __name__ == "__main__":
    unittest.main()
