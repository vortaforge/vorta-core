#!/usr/bin/env python3
"""
Run macroEngine's validators over a datapack on disk.

The Java validator runs inside the game, where the pack stack is only visible
after world load. That makes it useless for the question a pack author asks first:
"will this produce a wall of false positives on my own pack?" This script answers
that before anything is launched, using the same rules.

The patterns here are a deliberate mirror of SuspiciousText.java, not an
independent implementation. If they diverge, the mirror is wrong - and
tools/test_scan_parity.py fails when they do.

Usage:
    python3 tools/scan_pack.py <pack-dir> [--json]
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

# --- mirror of SuspiciousText.INJECTION ------------------------------------
INJECTION = [
    r"\bignore\s+(?:all\s+|any\s+)?(?:the\s+|your\s+)?(?:previous|prior|above|preceding|earlier)\b",
    r"\bdisregard\s+(?:all\s+|any\s+)?(?:the\s+|your\s+)?(?:previous|prior|above|preceding|earlier|instructions?|rules?)\b",
    r"\bforget\s+(?:everything|all|your|the)\b.{0,20}\b(?:instructions?|rules?|above|prompt)\b",
    r"\byou\s+are\s+(?:now|no\s+longer)\s+(?:an?\s+|the\s+)?(?:unrestricted|unfiltered|jailbroken|uncensored|liberated|dan\b|admin(?:istrator)?\b|root\b|assistant\b|ai\b|language\s+model\b|free\s+from|bound\s+by|subject\s+to\s+no)",
    r"\b(?:act|behave)\s+as\s+(?:if\s+you\s+(?:are|were)\s+)?(?:a\s+|an\s+)?(?:admin|administrator|root|system|developer|ai|assistant)\b",
    r"\bnew\s+(?:system\s+)?(?:instructions?|rules?|prompt)\b",
    r"\bsystem\s*prompt\b",
    r"\b(?:reveal|print|show|repeat|output)\s+(?:me\s+)?(?:your|the)\s+(?:system\s+)?(?:prompt|instructions?|rules?)\b",
    r"\b(?:ai|llm|language\s+model|assistant|agent|chatgpt|claude|copilot|gemini)\s+(?:must|should|shall|will|needs?\s+to)\b",
    r"\bif\s+you\s+are\s+(?:an?\s+)?(?:ai|llm|language\s+model|bot|assistant|agent)\b",
    r"\b(?:base64|rot13|hex)\s*(?:-|:)?\s*(?:decode|encoded|encode)\b",
    r"</?(?:system|instruction|prompt|assistant|user)>",
    r"(?:^|\s)(?:###|===|---)\s*(?:system|instruction|prompt)\b",
]

LINK = [r"https?://[^\s\"'<>)\]]+", r"\bwww\.[a-z0-9-]+(?:\.[a-z0-9-]+)+"]

KNOWN_HOSTS = {
    "vortaforge.github.io", "github.com", "raw.githubusercontent.com",
    "minecraft.wiki", "minecraft.net",
}

BAD_LINK_SHAPE = [
    r"https?://\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}",
    r"https?://[^\s/]*(?:bit\.ly|tinyurl|t\.co|goo\.gl|is\.gd|shorturl|rebrand\.ly)",
    r"https?://[^\s/]*(?:pastebin|hastebin|ghostbin|termbin|transfer\.sh)",
    r"https?://[^\s/]*xn--",
]

EXECUTION_BAIT = re.compile(
    r"\b(?:run|execute|paste|install|download\s+and\s+run|chmod\s*\+x|curl\b.*\|\s*(?:sh|bash)|powershell\s+-|"
    r"\.exe\b|\.bat\b|\.jar\b|\.msi\b|npm\s+install|pip\s+install)\b",
    re.IGNORECASE,
)

INJECTION_RE = [(p, re.compile(p, re.IGNORECASE)) for p in INJECTION]
LINK_RE = [re.compile(p, re.IGNORECASE) for p in LINK]
BAD_RE = [re.compile(p, re.IGNORECASE) for p in BAD_LINK_SHAPE]


def host_of(url: str):
    m = re.match(r"^[a-z]+://([^/?#]*)", url, re.IGNORECASE)
    host = m.group(1) if m else url.split("/")[0]
    host = host.rsplit("@", 1)[-1].split(":")[0]
    return host or None


def known(host: str) -> bool:
    return any(host == k or host.endswith("." + k) for k in KNOWN_HOSTS)


def scan_text(text: str, where: str):
    out = []
    for _src, rx in INJECTION_RE:
        for m in rx.finditer(text):
            out.append({"severity": "HIGH", "kind": "prompt-injection", "where": where,
                        "snippet": text[max(0, m.start() - 24):m.end() + 24].replace("\n", " ").strip()})
    seen = set()
    for rx in LINK_RE:
        for m in rx.finditer(text):
            url = m.group()
            if url in seen:
                continue
            seen.add(url)
            low = url.lower()
            if any(b.search(low) for b in BAD_RE):
                out.append({"severity": "HIGH", "kind": "suspicious-link", "where": where, "snippet": url})
                continue
            host = host_of(low)
            if host and not known(host):
                out.append({"severity": "WARN", "kind": "off-site-link", "where": where, "snippet": url})
            window = text[max(0, m.start() - 120):m.end() + 120]
            if EXECUTION_BAIT.search(window):
                out.append({"severity": "HIGH", "kind": "link-with-execution", "where": where, "snippet": url})
    return out


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 2
    root = Path(argv[1]).resolve()
    as_json = "--json" in argv
    if not root.is_dir():
        print(f"not a directory: {root}")
        return 2

    findings = []
    files = 0
    for path in sorted(root.rglob("*")):
        if not path.is_file():
            continue
        if path.suffix not in {".json", ".mcfunction", ".md", ".txt"}:
            continue
        files += 1
        try:
            text = path.read_text(encoding="utf-8")
        except (UnicodeDecodeError, OSError):
            continue
        findings.extend(scan_text(text, str(path.relative_to(root))))

    result = {
        "root": str(root),
        "filesScanned": files,
        "findings": findings,
        "counts": {sev: sum(1 for f in findings if f["severity"] == sev) for sev in ("HIGH", "WARN")},
    }
    if as_json:
        print(json.dumps(result, indent=2))
    else:
        print(f"scanned {files} file(s) under {root}")
        print(f"  HIGH: {result['counts']['HIGH']}   WARN: {result['counts']['WARN']}")
        for f in findings[:40]:
            print(f"  [{f['severity']}] {f['kind']} {f['where']}: {f['snippet']}")
        if len(findings) > 40:
            print(f"  ... and {len(findings) - 40} more")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
