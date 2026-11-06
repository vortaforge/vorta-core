#!/usr/bin/env python3
"""Remove the maintainer-handover notice and HANDOVER.md from the repository.

Run from the repository root:
    python3 remove_handover.py
CREDITS.md is a historical changelog and is intentionally left untouched.
"""
import re
import subprocess
from pathlib import Path

# 1. Delete every HANDOVER.md (tracked files via git, untracked via unlink).
for path in sorted(Path(".").rglob("HANDOVER*.md")):
    if ".git" in path.parts or "node_modules" in path.parts:
        continue
    tracked = subprocess.run(["git", "ls-files", "--error-unmatch", str(path)],
                             capture_output=True).returncode == 0
    if tracked:
        subprocess.run(["git", "rm", "-q", str(path)], check=True)
    else:
        path.unlink()
    print(f"removed {path}")

# 2. README.md: drop the whole "## Maintenance status" section.
readme = Path("README.md")
text = readme.read_text(encoding="utf-8")
new = re.sub(r"## Maintenance status\n.*?(?=^## )", "", text, flags=re.S | re.M)
if new != text:
    readme.write_text(new, encoding="utf-8")
    print("README.md: removed 'Maintenance status' section")

# 3. docs/MAINTAINER_GUIDE.md: remove the dangling HANDOVER.md reference.
guide = Path("docs/MAINTAINER_GUIDE.md")
text = guide.read_text(encoding="utf-8")
new = text.replace("The canonical checks and their prerequisites are documented in `README.md`\nand `HANDOVER.md`. In brief:",
                   "The canonical checks and their prerequisites are documented in `README.md`.\nIn brief:")
if new != text:
    guide.write_text(new, encoding="utf-8")
    print("docs/MAINTAINER_GUIDE.md: removed HANDOVER.md reference")

# 4. Report anything that still mentions it (CREDITS.md history is expected).
left = subprocess.run(["git", "grep", "-n", "-I", "HANDOVER"], capture_output=True, text=True).stdout
print("remaining references:\n" + (left or "  none"))
