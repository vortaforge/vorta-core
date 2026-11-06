#!/usr/bin/env python3
"""
Guard against the Python mirror and the Java validator drifting apart.

tools/scan_pack.py exists so a pack author can check their own pack without
launching the game. It re-implements SuspiciousText's rules in Python, which means
there are now two copies of the same specification - exactly the setup that rots
quietly when someone edits one and forgets the other.

This test fails when they disagree, so the mirror cannot silently become stale.
"""
from __future__ import annotations

import re
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
JAVA = HERE.parent / "src/main/java/net/vortaforge/macroengine/validate/SuspiciousText.java"
PY = HERE / "scan_pack.py"


def _load_scan_pack():
    import importlib.util

    spec = importlib.util.spec_from_file_location("scan_pack", PY)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


class MirrorParity(unittest.TestCase):
    def _java_block(self, name: str) -> str:
        """The text of one `private static final List<Pattern> NAME = List.of(...)`."""
        src = JAVA.read_text(encoding="utf-8")
        start = src.index(f"{name} = List.of(")
        end = src.index(");", start)
        return src[start:end]

    def test_injection_rule_count_matches(self):
        # Count only the INJECTION block. Counting every Pattern.compile in the file
        # also picks up the link and execution rules, and comparing that number to
        # the injection list compares two different things.
        java_count = self._java_block("INJECTION").count("Pattern.compile(")
        py_count = len(_load_scan_pack().INJECTION)
        self.assertEqual(
            java_count, py_count,
            f"the Java validator has {java_count} injection rule(s) but the Python "
            f"mirror has {py_count}. A rule was added or removed on one side only. "
            f"Update tools/scan_pack.py and SuspiciousText.java together.",
        )

    def test_known_hosts_match(self):
        java = JAVA.read_text(encoding="utf-8")
        block = java[java.index("KNOWN_HOSTS = Set.of("):]
        block = block[: block.index(");")]
        java_hosts = set(re.findall(r'"([a-z0-9.-]+\.[a-z]{2,})"', block))
        py_hosts = set(_load_scan_pack().KNOWN_HOSTS)

        self.assertEqual(
            java_hosts, py_hosts,
            "the known-host allowlist differs between SuspiciousText.java and "
            "tools/scan_pack.py. A host added to one side only means the game and the "
            "offline checker disagree about what counts as off-site.",
        )

    def test_every_java_rule_is_valid_in_python(self):
        """A regex that compiles in Java but not in Python would make the mirror lie."""
        for pattern in _load_scan_pack().INJECTION:
            import re as _re
            _re.compile(pattern)  # raises re.error if malformed


if __name__ == "__main__":
    unittest.main(verbosity=2)
