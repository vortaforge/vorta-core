"""Focused, offline repository safeguards and their negative controls.

These tests replace selected local high-severity audit checks, not the old
GitHub/org audit. They never start or contact a Minecraft server.

2026-11-05: the datapack programme was archived (archived/archive.json). The
live-tree checks that used to scan packs/ now scan archived/packs/ as well, so
the archived packs stay statically honest, and new tests assert that the live
tree stays datapack-free.
"""
from __future__ import annotations

import json
import os
from pathlib import Path
import re
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
SKIP_DIRS = {".git", ".gradle", ".toolchains", ".cache", "build", "node_modules", "__pycache__"}
NAMESPACE = re.compile(r"^[a-z0-9_.-]+$")
NBT_FILTER_AFTER_INDEX = re.compile(r"(?<=[\w\]])\[-?\d+\]\{")
QUOTED = re.compile(r'"(?:[^"\\]|\\.)*"|\'(?:[^\'\\]|\\.)*\'')
FUNCTION_CALL = re.compile(r"(?<![\w:#$])function\s+([a-z0-9_.-]+:[a-z0-9_./-]+)", re.I)
SECRET_PATTERNS = (
    ("GitHub fine-grained token", re.compile(r"github_pat_[A-Za-z0-9_]{20,}")),
    ("GitHub token", re.compile(r"gh[pousr]_[A-Za-z0-9]{36,}")),
    ("Slack token", re.compile(r"xox[baprs]-[A-Za-z0-9-]{10,}")),
    ("private key", re.compile(r"-----BEGIN [A-Z ]*PRIVATE KEY-----")),
    ("AWS access key", re.compile(r"AKIA[0-9A-Z]{16}")),
)
BINARY_EXTENSIONS = {".jar", ".class", ".png", ".jpg", ".jpeg", ".gif", ".webp", ".ico", ".zip", ".gz",
                     ".7z", ".ogg", ".mp3", ".mp4", ".ttf", ".otf", ".woff", ".woff2", ".nbt", ".dat", ".pdf"}


def walk_files(root: Path):
    for current, dirs, files in os.walk(root, followlinks=False):
        dirs[:] = sorted(d for d in dirs if d not in SKIP_DIRS and not Path(current, d).is_symlink())
        for name in sorted(files):
            path = Path(current, name)
            if not path.is_symlink():
                yield path


def pack_roots(packs: Path):
    return sorted(p.parent for p in walk_files(packs) if p.name == "pack.mcmeta")


def format_pair(value):
    if isinstance(value, int) and not isinstance(value, bool) and value >= 0:
        return value, 0
    if (isinstance(value, list) and len(value) == 2 and
            all(isinstance(x, int) and not isinstance(x, bool) and x >= 0 for x in value)):
        return tuple(value)
    raise ValueError(f"invalid pack format: {value!r}")


def validate_layout(packs: Path):
    problems = []
    if not packs.is_dir():
        return ["packs directory is missing"]
    for child in packs.iterdir():
        if child.is_dir() and (child / "data").is_dir() and not (child / "pack.mcmeta").is_file():
            problems.append(f"{child}: data directory has no pack.mcmeta")
    for pack_root in pack_roots(packs):
        meta = pack_root / "pack.mcmeta"
        try:
            doc = json.loads(meta.read_text(encoding="utf-8"))
            pack = doc["pack"]
            if not isinstance(pack, dict):
                raise ValueError("pack is not an object")
            low = format_pair(pack.get("min_format", pack.get("pack_format")))
            high = format_pair(pack.get("max_format", pack.get("pack_format")))
            if low > high:
                raise ValueError("minimum format exceeds maximum")
        except (OSError, UnicodeError, ValueError, KeyError, TypeError) as error:
            problems.append(f"{meta}: invalid metadata ({error})")
            continue
        data = pack_root / "data"
        if not data.is_dir():
            continue  # Resource packs have assets instead of data.
        for ns in sorted(p for p in data.iterdir() if p.is_dir()):
            if not NAMESPACE.fullmatch(ns.name):
                problems.append(f"{ns}: invalid namespace")
            singular, plural = ns / "function", ns / "functions"
            if singular.is_dir() and plural.is_dir():
                dead = plural if low[0] >= 48 else singular
                if any(p.suffix == ".mcfunction" for p in walk_files(dead)):
                    problems.append(f"{ns}: both function and functions directories contain incompatible files")
            tags = ns / "tags"
            if not tags.is_dir():
                continue
            if (tags / "function").is_dir() and (tags / "functions").is_dir():
                problems.append(f"{tags}: both function tag directory spellings exist")
            for file in walk_files(tags):
                if file.suffix == ".mcfunction":
                    problems.append(f"{file}: function file is inside tags")
                elif file.suffix == ".json":
                    try:
                        tag = json.loads(file.read_text(encoding="utf-8"))
                        if not isinstance(tag, dict) or ("values" in tag and not isinstance(tag["values"], list)):
                            raise ValueError("tag must be an object with list-valued values")
                    except (OSError, UnicodeError, ValueError) as error:
                        problems.append(f"{file}: invalid tag ({error})")
    return problems


def index_functions(roots):
    functions, tags = set(), set()
    for root in roots:
        data = root / "data"
        if not data.is_dir():
            continue
        for ns in (p for p in data.iterdir() if p.is_dir()):
            for kind in ("function", "functions"):
                function_dir, tag_dir = ns / kind, ns / "tags" / kind
                if function_dir.is_dir():
                    for file in walk_files(function_dir):
                        if file.suffix == ".mcfunction":
                            functions.add(f"{ns.name}:{file.relative_to(function_dir).with_suffix('').as_posix()}")
                if tag_dir.is_dir():
                    for file in walk_files(tag_dir):
                        if file.suffix == ".json":
                            tags.add(f"{ns.name}:{file.relative_to(tag_dir).with_suffix('').as_posix()}")
    return functions, tags


def required_tag_reference_problems(roots):
    functions, tags = index_functions(roots)
    problems = []
    for root in roots:
        data = root / "data"
        if not data.is_dir():
            continue
        for ns in (p for p in data.iterdir() if p.is_dir()):
            for kind in ("function", "functions"):
                directory = ns / "tags" / kind
                if not directory.is_dir():
                    continue
                for file in walk_files(directory):
                    if file.suffix != ".json":
                        continue
                    try:
                        doc = json.loads(file.read_text(encoding="utf-8"))
                    except (ValueError, OSError, UnicodeError):
                        continue  # The layout test reports malformed JSON separately.
                    if not isinstance(doc, dict) or not isinstance(doc.get("values"), list):
                        continue
                    for value in doc["values"]:
                        if isinstance(value, dict):
                            if value.get("required") is False:
                                continue
                            value = value.get("id")
                        if not isinstance(value, str):
                            problems.append(f"{file}: invalid required tag value")
                            continue
                        is_tag = value.startswith("#")
                        identifier = value[1:] if is_tag else value
                        if ":" not in identifier:
                            identifier = "minecraft:" + identifier
                        if identifier not in (tags if is_tag else functions):
                            problems.append(f"{file}: required {'tag' if is_tag else 'function'} {value} is unresolved")
    return problems


def merged_function_reference_problems(packs: Path):
    try:
        manifest = json.loads((packs / "merge-manifest.json").read_text(encoding="utf-8"))
        include = manifest["include"]
        excluded = set(manifest.get("exclude", []))
        if not isinstance(include, list) or (not include and not manifest.get("allowEmpty", False)):
            raise ValueError("include must be a nonempty list unless allowEmpty is true")
        roots = []
        for entry in include:
            if not isinstance(entry, str) or entry in excluded:
                if not isinstance(entry, str):
                    raise ValueError("pack names must be strings")
                continue
            path = (packs / entry).resolve()
            if packs.resolve() not in path.parents or not (path / "pack.mcmeta").is_file():
                raise ValueError(f"included pack is missing or outside packs/: {entry}")
            roots.append(path)
    except (OSError, UnicodeError, KeyError, TypeError, ValueError) as error:
        return [f"merge manifest invalid: {error}"]
    functions, _tags = index_functions(roots)
    problems = []
    for root in roots:
        for file in walk_files(root):
            if file.suffix != ".mcfunction":
                continue
            for line_no, line in enumerate(file.read_text(encoding="utf-8").splitlines(), 1):
                if line.lstrip().startswith("#"):
                    continue
                for match in FUNCTION_CALL.finditer(line):
                    target = match.group(1).rstrip("/")
                    # Macro-generated destinations and Minecraft built-ins cannot be
                    # resolved from this repository's static files.
                    if target.startswith("minecraft:") or line[match.end():].startswith(("$", "%")):
                        continue
                    if target not in functions:
                        problems.append(f"{file}:{line_no}: unresolved merged function {target}")
    return problems


def invalid_nbt_path_lines(text):
    return [number for number, line in enumerate(text.splitlines(), 1)
            if not line.lstrip().startswith("#") and NBT_FILTER_AFTER_INDEX.search(QUOTED.sub('""', line))]


def secret_labels(text):
    return [label for label, pattern in SECRET_PATTERNS if pattern.search(text)]


class EnglishOnly(unittest.TestCase):
    """The repository is English-only; a regression here is a review failure.

    Turkish text used to appear in documentation, alerts, the archive registry
    and even in script output (`sebep (tr): ...`). All of it was removed on
    2026-11-05. `archived/packs/` is exempt: those are frozen upstream
    artefacts whose bytes are provenance, and they are never edited again.
    """

    #: Turkish-specific letters. The official name of a Turkish regulatory
    #: decision is quoted in a citation (README, CREDITS) and is not text this
    #: repository wrote; see ALLOWED below.
    TURKISH = re.compile(r"[\u011F\u011E\u0131\u0130\u015F\u015E\u00F6\u00D6\u00FC\u00DC\u00E7\u00C7]")

    #: (path, needle that is allowed despite matching the pattern above)
    ALLOWED = [
        ("README.md", "DK-\u0130D"),
        ("CREDITS.md", "DK-\u0130D"),
        # The macroEngine docs cite Turkish Law 5651 by name when explaining which
        # jurisdictions regulate platforms. "T\u00fcrkiye" is a proper noun in a legal
        # citation, not Turkish prose, and renaming it would make the citation
        # unfindable to anyone checking it.
        ("mods/macroengine/INFO.md", "T\u00fcrkiye"),
        ("mods/macroengine/src/main/resources/data/macroengine/dialog/gate/warning.json",
         "T\u00fcrkiye"),
    ]

    #: This file has to spell out the pattern it searches for, so it cannot be
    #: its own subject.
    SELF = "scripts/tests/test_repository_safeguards.py"

    # Matched segment-wise, not as a string prefix: a Gradle subproject writes its
    # own build/ and dist/ (mods/x/build/...), and the original string-prefix form
    # only ever excluded the repository-root ones. Generated output is not prose and
    # must not be reported as a language violation in either case.
    EXCLUDED_PREFIXES = ("archived/packs/", ".git/")
    EXCLUDED_SEGMENTS = {"build", "dist", "node_modules", "__pycache__", ".gradle", ".git"}
    SUFFIXES = (".md", ".py", ".json", ".yml", ".yaml", ".gradle", ".html",
                ".mjs", ".sh", ".properties", ".toml")

    def test_no_turkish_text_in_the_live_tree(self):
        offenders = []
        for path in ROOT.rglob("*"):
            if not path.is_file():
                continue
            rel = path.relative_to(ROOT).as_posix()
            if rel == self.SELF:
                continue
            if any(rel.startswith(prefix) for prefix in self.EXCLUDED_PREFIXES):
                continue
            if self.EXCLUDED_SEGMENTS.intersection(rel.split("/")[:-1]):
                continue
            if not rel.endswith(self.SUFFIXES):
                continue
            try:
                text = path.read_text(encoding="utf-8")
            except UnicodeDecodeError:
                continue   # binary asset, not prose
            for number, line in enumerate(text.splitlines(), 1):
                if not self.TURKISH.search(line):
                    continue
                if any(rel == allowed_path and allowed_text in line
                       for allowed_path, allowed_text in self.ALLOWED):
                    continue
                offenders.append(f"{rel}:{number}: {line.strip()[:120]}")
        self.assertEqual(offenders, [],
                         "Turkish text found in the live tree:\n" + "\n".join(offenders))

    def test_maintainer_guide_states_the_rule(self):
        guide = (ROOT / "docs" / "MAINTAINER_GUIDE.md").read_text(encoding="utf-8")
        self.assertIn("Use English, only English", guide)

    def test_no_turkish_reason_field_survives(self):
        # `reason_tr` was removed from the registry, the schema, the switch file
        # and the switch CLI together; a partial removal would rot silently.
        for rel in ("archived/archive.json", "archived/archive.schema.json",
                    "datapacks.disabled.json"):
            with self.subTest(path=rel):
                self.assertNotIn("reason_tr", (ROOT / rel).read_text(encoding="utf-8"))
        cli = (ROOT / "scripts" / "repo" / "datapacks_disable.py").read_text(encoding="utf-8")
        self.assertNotIn("reason_tr", cli)
        self.assertNotIn("sebep (tr)", cli)


class LiveTreeSafeguards(unittest.TestCase):
    """The archived packs are still parsed, so a regression there is caught.

    `archived/packs/` is reference-only, but it is the largest body of
    mcfunction in the repository and a future restore would start from it.
    """

    PACKS = ROOT / "archived" / "packs"

    def test_pack_metadata_layout_and_tag_shapes(self):
        self.assertEqual(validate_layout(self.PACKS), [])

    def test_required_function_tag_values_resolve_somewhere_in_tree(self):
        self.assertEqual(required_tag_reference_problems(pack_roots(self.PACKS)), [])

    def test_archived_merge_manifest_is_internally_consistent(self):
        # The manifest is archived next to the packs it used to merge; its
        # "include" entries must still name real archived packs (or be empty).
        manifest = ROOT / "archived" / "merge-manifest.json"
        self.assertTrue(manifest.is_file(), "archived/merge-manifest.json is missing")
        data = json.loads(manifest.read_text(encoding="utf-8"))
        include = data.get("include", [])
        self.assertIsInstance(include, list)
        for entry in include:
            path = (self.PACKS / entry).resolve()
            self.assertIn(str(self.PACKS.resolve()), str(path), f"include escapes archived/packs: {entry}")

    def test_live_packs_tree_is_empty(self):
        packs = ROOT / "packs"
        allowed = {"README.md", ".gitkeep"}
        leftovers = sorted(p.name for p in packs.iterdir()
                           if p.name not in allowed) if packs.is_dir() else []
        self.assertEqual(leftovers, [], "packs/ must stay empty: new datapacks are blocked")

    def test_no_live_datapack_tooling(self):
        for live in ("scripts/dpgen", "scripts/datapack_lint", "scripts/lint_datapacks.sh",
                     "scripts/ward_ci.sh", "scripts/ward_guard.py", "mods/datapack-blocker",
                     "examples/template-datapack", ".github/workflows/ward.yml"):
            with self.subTest(live=live):
                self.assertFalse((ROOT / live).exists(), f"{live} must stay archived")

    def test_invalid_nbt_filter_after_index_is_absent(self):
        problems = []
        for file in walk_files(self.PACKS):
            if file.suffix == ".mcfunction":
                problems.extend(f"{file.relative_to(ROOT)}:{line}" for line in invalid_nbt_path_lines(file.read_text(encoding="utf-8")))
        self.assertEqual(problems, [])

    def test_dpgen_license_metadata_matches_its_existing_license(self):
        dpgen = ROOT / "archived" / "tools" / "dpgen"
        package = json.loads((dpgen / "package.json").read_text(encoding="utf-8"))
        lock = json.loads((dpgen / "package-lock.json").read_text(encoding="utf-8"))
        self.assertEqual(package["license"], "Unlicense")
        self.assertEqual(lock["packages"][""]["license"], package["license"])
        self.assertIn("free and unencumbered software", (dpgen / "LICENSE").read_text(encoding="utf-8"))

    def test_linter_license_and_dependency_notices_are_present(self):
        lint = ROOT / "archived" / "tools" / "datapack-lint"
        package = json.loads((lint / "package.json").read_text(encoding="utf-8"))
        lock = json.loads((lint / "package-lock.json").read_text(encoding="utf-8"))
        self.assertEqual(package["license"], "Unlicense")
        self.assertEqual(lock["packages"][""]["license"], package["license"])
        self.assertEqual((lint / "LICENSE").read_bytes(), (ROOT / "LICENSE").read_bytes())
        notices = (lint / "THIRD_PARTY_NOTICES.md").read_text(encoding="utf-8")
        for text in ("SPGoding and SpyglassMC contributors", "Microsoft Corporation", "Kevin Mårtensson", "MIT License"):
            self.assertIn(text, notices)

    def test_macroengine_mit_notice_is_present(self):
        pack = ROOT / "archived" / "packs" / "macroEngine-Datapack-v26.3"
        notice = (pack / "THIRD_PARTY_LICENSES.md").read_text(encoding="utf-8")
        self.assertIn("MIT License", notice)
        self.assertIn("Copyright (c) 2022 Michael Weatherby", notice)
        self.assertTrue((pack / "LICENSE").is_file())

    def test_common_credential_shapes_absent_from_text(self):
        problems = []
        for file in walk_files(ROOT):
            if file.suffix.lower() in BINARY_EXTENSIONS or file.stat().st_size > 2_000_000:
                continue
            try:
                labels = secret_labels(file.read_text(encoding="utf-8"))
            except (UnicodeError, OSError):
                continue
            if labels:
                # Report only the path and type, never the matched secret.
                problems.append(f"{file.relative_to(ROOT)}: {', '.join(labels)}")
        self.assertEqual(problems, [], "possible credentials; inspect privately, not in public logs")


class NegativeControls(unittest.TestCase):
    def test_layout_detects_missing_metadata_bad_namespace_and_reversed_format(self):
        with tempfile.TemporaryDirectory(prefix="vorta-layout-") as tmp:
            packs = Path(tmp)
            (packs / "missing" / "data").mkdir(parents=True)
            broken = packs / "broken"
            (broken / "data" / "Bad Namespace").mkdir(parents=True)
            (broken / "pack.mcmeta").write_text('{"pack":{"min_format":10,"max_format":1}}', encoding="utf-8")
            self.assertTrue(any("no pack.mcmeta" in s for s in validate_layout(packs)))
            self.assertTrue(any("minimum format" in s for s in validate_layout(packs)))
            (broken / "pack.mcmeta").write_text('{"pack":{"min_format":1,"max_format":1}}', encoding="utf-8")
            self.assertTrue(any("invalid namespace" in s for s in validate_layout(packs)))

    def test_required_but_not_optional_missing_tag_is_rejected(self):
        with tempfile.TemporaryDirectory(prefix="vorta-tags-") as tmp:
            root = Path(tmp)
            tag = root / "data" / "minecraft" / "tags" / "function" / "load.json"
            tag.parent.mkdir(parents=True)
            tag.write_text('{"values":["demo:missing", {"id":"demo:optional","required":false}]}', encoding="utf-8")
            problems = required_tag_reference_problems([root])
            self.assertEqual(len(problems), 1)
            self.assertIn("demo:missing", problems[0])

    def test_missing_merged_function_is_rejected(self):
        with tempfile.TemporaryDirectory(prefix="vorta-merge-") as tmp:
            packs = Path(tmp)
            pack = packs / "demo"
            function = pack / "data" / "demo" / "function" / "run.mcfunction"
            function.parent.mkdir(parents=True)
            (pack / "pack.mcmeta").write_text('{"pack":{"pack_format":121}}', encoding="utf-8")
            (packs / "merge-manifest.json").write_text('{"include":["demo"]}', encoding="utf-8")
            function.write_text('function demo:missing\n', encoding="utf-8")
            self.assertTrue(any("demo:missing" in s for s in merged_function_reference_problems(packs)))
            function.write_text('$function demo:$(target)\n', encoding="utf-8")
            self.assertEqual(merged_function_reference_problems(packs), [])

    def test_nbt_path_rejects_unquoted_filter_after_index(self):
        self.assertEqual(invalid_nbt_path_lines('data get storage demo:x a[0]{foo:1}\n'), [1])
        self.assertEqual(invalid_nbt_path_lines('say "a[0]{foo:1}"\n# a[0]{foo:1}\n'), [])

    def test_secret_scan_detects_samples_without_returning_values(self):
        sample = "gh" + "p_" + "A" * 36
        self.assertIn("GitHub token", secret_labels(sample))
        self.assertNotIn(sample, secret_labels(sample))






class BackupSafety(unittest.TestCase):
    """The backup path must not mix a credential with unpinned or plaintext data.

    Audit 2026-11-05: `pip install github-backup` resolved a floating version
    while GH_TOKEN was exported, and ENCRYPT defaulted to `none` even though
    the workflow uploads the archive as an artifact for 14 days.
    """

    @staticmethod
    def _code(text: str) -> str:
        """Drop full-line and trailing `#` comments.

        The script documents the old behaviour it removed ("pip install
        github-backup resolved whatever was newest"), so matching the raw file
        finds the explanation instead of the code. Assertions must read code.
        """
        out = []
        for line in text.splitlines():
            stripped = line.lstrip()
            if stripped.startswith("#"):
                continue
            out.append(line.split("  #", 1)[0] if "  #" in line else line)
        return "\n".join(out)

    def setUp(self):
        self.script = self._code(
            (ROOT / "scripts" / "ops" / "backup-org.sh").read_text(encoding="utf-8"))
        self.raw_script = (ROOT / "scripts" / "ops" / "backup-org.sh").read_text(encoding="utf-8")
        self.workflow = (ROOT / ".github" / "workflows" / "backup-org.yml").read_text(encoding="utf-8")

    def test_dependency_is_pinned_and_hash_checked(self):
        self.assertNotRegex(self.script, r"pip install[^\n]*github-backup(?![=])",
                            "an unpinned `pip install github-backup` is back")
        self.assertIn("--require-hashes", self.script)
        self.assertRegex(self.script, r'GHBK_VERSION="\$\{GHBK_VERSION:-[0-9]+\.[0-9]+\.[0-9]+\}"')
        self.assertRegex(self.script, r'GHBK_HASH="\$\{GHBK_HASH:-[0-9a-f]{64}\}"')

    def test_install_runs_without_the_token_in_the_environment(self):
        self.assertTrue(any("env -u GH_TOKEN" in l for l in self.script.splitlines()),
                        "the pip install no longer clears the token")

    def test_install_is_isolated_in_a_venv(self):
        self.assertIn("python3 -m venv", self.script)
        self.assertIn("GHBK_VENV", self.script)
        self.assertNotIn("--break-system-packages", self.script)

    def test_unencrypted_archive_cannot_be_uploaded(self):
        self.assertIn("UPLOAD_ARCHIVE", self.script)
        self.assertIn("ENCRYPT=none refused", self.script)
        self.assertIn('UPLOAD_ARCHIVE: "1"', self.workflow)
        self.assertNotIn("options: [gpg, 7z, none]", self.workflow)
        upload = self.workflow.split("Upload archive", 1)[1]
        self.assertNotIn("*.tar.gz\n", upload)

    def test_encryption_defaults_to_gpg(self):
        self.assertRegex(self.script, r'ENCRYPT="\$\{ENCRYPT:-gpg\}"')
        self.assertIn("default: gpg", self.workflow)

    def test_workflow_still_fails_without_a_passphrase(self):
        self.assertIn("BACKUP_ARCHIVE_PASSWORD secret set", self.workflow)


class VersionMatrix(unittest.TestCase):
    """docs/VERSION_MATRIX.md must describe the build files that exist.

    The audit of 2026-11-05 found the supported-version story untracked: the
    two shipped mods target 1.21.1, the example targets a newer line, and only
    the template floated on a Loom -SNAPSHOT. A table nobody verifies becomes
    wrong on the next bump, so this compares it to the source of truth.
    """

    PROJECTS = {
        "mods/afk-manager": "1.21.1",
        "mods/join-throttle": "1.21.1",
        "examples/opmod-example": "26.3",
        "mods/TEMPLATE-MOD": "26.1.2",
    }

    def _properties(self, project):
        text = (ROOT / project / "gradle.properties").read_text(encoding="utf-8")
        out = {}
        for line in text.splitlines():
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                key, _, value = line.partition("=")
                out[key.strip()] = value.strip()
        return out

    def test_documented_minecraft_versions_match_the_files(self):
        doc = (ROOT / "docs" / "VERSION_MATRIX.md").read_text(encoding="utf-8")
        for project, expected in self.PROJECTS.items():
            actual = self._properties(project)["minecraft_version"]
            self.assertEqual(actual, expected, f"{project} minecraft_version")
            # The row must name both the project and its version.
            row = [l for l in doc.splitlines() if f"`{project}`" in l]
            self.assertTrue(row, f"VERSION_MATRIX has no row for {project}")
            self.assertIn(expected, row[0], f"{project} row is stale: {row[0]}")

    def test_no_floating_build_tool_versions(self):
        # A -SNAPSHOT or a bare '+' lets an unchanged commit build against
        # different tool code tomorrow.
        checked = 0
        for base in ("mods", "examples"):
            for props in (ROOT / base).rglob("gradle.properties"):
                for key, value in self._properties(props.parent).items():
                    if key.endswith("_version"):
                        checked += 1
                        self.assertNotIn("-SNAPSHOT", value,
                                         f"{props}: {key} is a snapshot")
                        self.assertNotEqual(value, "+", f"{props}: {key} floats")
                        self.assertFalse(value.endswith("+"),
                                         f"{props}: {key} floats")
        self.assertGreater(checked, 0, "no version properties found")

    def test_loom_is_the_same_pinned_release_everywhere(self):
        versions = set()
        for build in list((ROOT / "mods").rglob("build.gradle")) + \
                     list((ROOT / "examples").rglob("build.gradle")):
            for line in build.read_text(encoding="utf-8").splitlines():
                match = re.search(r"id\s+['\"]fabric-loom['\"]\s+version\s+['\"]([^'\"]+)['\"]", line)
                if match:
                    versions.add(match.group(1))
        self.assertTrue(versions, "no fabric-loom plugin declarations found")
        self.assertEqual(len(versions), 1, f"Loom versions diverge: {versions}")
        self.assertNotIn("-SNAPSHOT", versions.pop())


class SiteDataSnapshot(unittest.TestCase):
    """The published snapshot must agree with the page it feeds.

    Regression (2026-11-05 audit): `index.html` was rewritten to never request
    the `packs-latest` release, but `build_site_data.php` still queried it and
    wrote pack download URLs into `_site/data/site-data.json`. The file was
    also referenced by nothing, so it was published dead weight that
    reintroduced exactly the datapack links the retirement removed.

    The builder is now `scripts/site/build_site_data.py` (see
    test_site_data.py for its behaviour); these assertions keep the *policy*
    that no pack data may reappear in either the builder or the page.
    """

    def setUp(self):
        self.builder = (ROOT / "scripts" / "site" / "build_site_data.py").read_text(encoding="utf-8")
        self.html = (ROOT / "index.html").read_text(encoding="utf-8")

    def test_builder_does_not_query_the_retired_release(self):
        self.assertNotIn("packs-latest", self.builder)
        self.assertNotIn("RELEASE_TAG", self.builder)
        self.assertNotIn("/releases/tags/", self.builder)

    def test_builder_emits_no_pack_fields(self):
        for legacy in ('"packs":', '"release":', '"noRelease":', "downloadUrl"):
            self.assertNotIn(legacy, self.builder, f"{legacy} is datapack-era output")
        self.assertIn('"datapacksRetired": True', self.builder)

    def test_builder_has_no_dead_pack_helpers(self):
        for gone in ("packs_from_assets", "pretty_name", "HISTORICAL_PACK_ASSETS",
                     "assetPrefix"):
            self.assertNotIn(gone, self.builder, f"{gone} is dead since the retirement")

    def test_page_does_not_fetch_the_retired_release(self):
        # The page and the snapshot must agree: neither may ask for packs.
        self.assertNotIn("releases/tags/", self.html)

    def test_pages_workflow_rejects_pack_data(self):
        workflow = (ROOT / ".github" / "workflows" / "pages.yml").read_text(encoding="utf-8")
        self.assertIn('data.get("packs")', workflow)
        self.assertIn("releases/download", workflow)
        # The old validator read data['packs'], which no longer exists.
        self.assertNotIn("len(data['packs'])", workflow)


class RepositoryLayout(unittest.TestCase):
    """The 2026-11-05 reorg must stay done: no half-moved tools, no dangling paths."""

    def test_no_live_datapack_generator(self):
        # Everything that emits datapack output lives under archived/ and is
        # registered there. A live generator would silently re-arm the programme.
        for live in ("scripts/gui_generator", "scripts/dpgen", "scripts/ward_guard.py"):
            self.assertFalse((ROOT / live).exists(), f"{live} is live again")

    def test_moved_scripts_sit_under_scripts_subdirectories(self):
        # scripts/ holds only grouping directories plus its README - repo checks
        # and git hooks each get one home instead of being scattered at the top.
        allowed_dirs = {"git", "ops", "repo", "site", "tests"}
        allowed_files = {"README.md"}
        for entry in (ROOT / "scripts").iterdir():
            if entry.name in ("__pycache__", ".pytest_cache"):
                continue
            if entry.is_dir():
                self.assertIn(entry.name, allowed_dirs, f"unexpected scripts/ dir {entry.name}")
            else:
                self.assertIn(entry.name, allowed_files, f"unexpected scripts/ file {entry.name}")

    def test_archived_tools_are_all_registered(self):
        registry = json.loads((ROOT / "archived" / "archive.json").read_text(encoding="utf-8"))
        registered = {p["path"].rstrip("/") for p in registry["projects"] if p.get("path")}
        for child in (ROOT / "archived" / "tools").iterdir():
            self.assertIn(f"archived/tools/{child.name}", registered, f"{child.name} is unregistered")

    def test_reorg_left_no_dangling_references(self):
        stale = ("scripts/gui_generator", "scripts/check_archive.py", ".githooks",
                 "scripts/datapack_guard.py", "scripts/datapacks_disable.py",
                 "scripts/origin_watermarks.py", "remove_handover.py")
        for name in stale:
            hits = []
            for path in ROOT.rglob("*"):
                rel = path.relative_to(ROOT).as_posix()
                if (not path.is_file() or rel.startswith(("archived/packs/", "archived/tools/"))
                        or "__pycache__" in rel or ".git/" in rel or "dist/" in rel):
                    continue
                if not rel.endswith((".md", ".py", ".gradle", ".yml", ".mjs", ".php", ".sh")):
                    continue
                # Files allowed to name a retired path because naming it is
                # the point: the guard denies it, this test asserts it, the
                # docs say where it went, and the watermark tool carries the
                # provenance wording that is embedded verbatim in the 15
                # archived (frozen) watermark files.
                if rel in (
                    "scripts/repo/check_archive.py",
                    "scripts/repo/origin_watermarks.py",
                    "scripts/tests/test_repository_safeguards.py",
                    "scripts/README.md",
                    "README.md",
                    "archived/README.md",
                ):
                    continue
                # Historical record, not live reference. CREDITS.md is a
                # date-stamped changelog ("Verified with scripts/x.py" describes
                # what ran on that day) and archived/ holds frozen artefacts -
                # including a patch series whose whole point is to reproduce an
                # older tree. Rewriting their paths would falsify the record.
                if rel in ("CREDITS.md",) or rel.startswith("archived/"):
                    continue
                text = path.read_text(encoding="utf-8", errors="ignore")
                if "LIVE_DATAPACK_PATHS" in text:
                    continue
                for line in text.splitlines():
                    if name in line and "archived/tools/" not in line:
                        hits.append(f"{rel}: {line.strip()[:90]}")
            self.assertEqual(hits, [], f"stale reference to {name}: {hits}")

    def test_scorecard_documents_the_real_layout(self):
        # The scorecard names every grouped directory; if one is renamed the
        # document becomes a lie, so make that a test failure.
        scorecard = (ROOT / "docs" / "SCORECARD.md").read_text(encoding="utf-8")
        for area in ("scripts/repo/", "scripts/git/", "scripts/ops/",
                     "scripts/site/", "scripts/tests/", "archived/tools/"):
            self.assertIn(area, scorecard, f"scorecard does not describe {area}")
            self.assertTrue((ROOT / area).is_dir(), f"{area} named but missing")

    def test_hooks_path_points_at_the_moved_hooks(self):
        for doc in ("README.md", "INSTALL.md", "NOTICE.md", "docs/ARCHIVAL.md",
                    "docs/MAINTAINER_GUIDE.md", "scripts/git/hooks/README.md"):
            text = (ROOT / doc).read_text(encoding="utf-8")
            self.assertNotIn("core.hooksPath .githooks", text, f"{doc} uses the old hooks path")
        self.assertTrue((ROOT / "scripts" / "git" / "hooks" / "pre-push").is_file())


if __name__ == "__main__":
    unittest.main()
