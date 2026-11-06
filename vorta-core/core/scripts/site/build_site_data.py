#!/usr/bin/env python3
"""Build-time data generator for the GitHub Pages page (index.html).

GitHub Pages only serves static files, so nothing runs when a visitor opens the
page. Instead this script runs inside .github/workflows/pages.yml, asks the
GitHub API for the mods/ directory using the workflow's GITHUB_TOKEN, and writes
the result to data/site-data.json. The page reads that file first (same origin,
no rate limit) and only falls back to calling the GitHub API from the browser if
the file is missing or stale.

Usage:   python3 scripts/site/build_site_data.py --out=_site/data/site-data.json
Env:     GITHUB_TOKEN       optional, raises the API rate limit; never printed
         GITHUB_REPOSITORY  optional, "owner/repo" (default vortaforge/core)
Exit:    0 on success, 1 on any API/IO failure (so a bad snapshot is never
         deployed over a good one).

This replaces build_site_data.php. The repository builds mods with Gradle and
tests with Python; PHP was a third toolchain that existed for this one 172-line
script and needed a third-party action (shivammathur/setup-php) pinning on every
run. Python 3 is already present on the GitHub-hosted runner and is already used
by the "Validate site" step three lines further down. The behaviour is a
line-for-line translation, and scripts/tests/test_site_data.py pins the parts
that matter (retry, fail-closed, filtering) without needing any network.

The filtering rules mirror modsFromContents() in index.html and must be kept in
sync with them.

AI involvement: written with Claude (Anthropic) at the request of the
maintainer. See CREDITS.md.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import time
import urllib.error
import urllib.request

DEFAULT_REPOSITORY = "vortaforge/core"
EXCLUDED_MODS = frozenset({"TEMPLATE-MOD", "datapack-fixer", "rtwrapper-mod"})
SAFE_DIR_NAME = re.compile(r"^[A-Za-z0-9._-]+$")
REPOSITORY_FORM = re.compile(r"^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$")
ATTEMPTS = 3


class BuildError(RuntimeError):
    """A condition that must abort the build rather than publish a bad snapshot."""


def fail(message: str) -> "NoReturn":  # noqa: F821 - typed via __future__ import
    raise BuildError(message)


def _get_once(url: str, token: str | None):
    """One HTTPS GET. Returns (status, decoded_json_or_None)."""
    request = urllib.request.Request(url, method="GET")
    request.add_header("Accept", "application/vnd.github+json")
    request.add_header("X-GitHub-Api-Version", "2022-11-28")
    request.add_header("User-Agent", "vortaforge-core-pages-build")
    if token:
        request.add_header("Authorization", f"Bearer {token}")

    # Refuse anything that is not https and refuse to follow a redirect: the
    # token is attached to this URL and must not be replayed to a host we did
    # not choose. urllib does not follow redirects for us by default, and the
    # scheme check is the equivalent of CURLPROTO_HTTPS / FOLLOWLOCATION=false.
    if not url.startswith("https://"):
        fail(f"refusing non-https URL: {url}")

    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            status = response.status
            body = response.read()
    except urllib.error.HTTPError as exc:
        status = exc.code
        body = exc.read() if exc.fp is not None else b""
    except (urllib.error.URLError, TimeoutError, OSError) as exc:
        raise _Retryable(f"network error ({exc})") from exc

    if status >= 500 or status == 429:
        raise _Retryable(f"HTTP {status}")
    if status == 404:
        return 404, None
    if not 200 <= status < 300:
        hint = ""
        if status in (403, 429):
            hint = " (API rate limit or blocked request; set GITHUB_TOKEN)"
        fail(f"GET {url} returned HTTP {status}{hint}")
    try:
        return status, json.loads(body.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError):
        fail(f"GET {url} returned invalid JSON")


class _Retryable(Exception):
    """Transient: worth another attempt before giving up."""


def github_get(url: str, token: str | None):
    """GET with three attempts and linear backoff (2s, 4s), as the PHP did."""
    last_error = "unknown error"
    for attempt in range(1, ATTEMPTS + 1):
        try:
            return _get_once(url, token)
        except _Retryable as exc:
            last_error = str(exc)
            if attempt < ATTEMPTS:
                time.sleep(attempt * 2)
    fail(f"GET {url} failed after {ATTEMPTS} attempts: {last_error}")


def mods_from_contents(items) -> list[dict]:
    """Filter the /contents/mods payload down to shippable mod directories."""
    if not isinstance(items, list):
        return []
    mods = []
    for item in items:
        if not isinstance(item, dict) or item.get("type") != "dir":
            continue
        name = item.get("name")
        if not isinstance(name, str):
            continue
        if name in EXCLUDED_MODS or not SAFE_DIR_NAME.match(name):
            continue
        mods.append({"name": name, "dir": name})
    mods.sort(key=lambda mod: mod["name"])
    return mods


def write_atomically(path: str, text: str) -> None:
    """Write via a .tmp sibling so a crash never leaves a half-written snapshot."""
    directory = os.path.dirname(path)
    if directory:
        os.makedirs(directory, exist_ok=True)
    tmp = path + ".tmp"
    with open(tmp, "w", encoding="utf-8") as handle:
        handle.write(text)
    os.replace(tmp, path)


def build(out: str, repository: str, token: str | None) -> int:
    if not REPOSITORY_FORM.match(repository):
        fail("GITHUB_REPOSITORY is not in owner/repo form")

    api = f"https://api.github.com/repos/{repository}"
    status, contents = github_get(api + "/contents/mods", token)
    if status == 404:
        fail("mods/ not found in the repository")

    mods = mods_from_contents(contents)
    if not mods:
        fail("mods/ contained no mod directories; refusing to publish an empty list")

    # Datapacks are retired (2026-11-05). The page no longer requests any
    # release, so the snapshot must not query one either: doing so published
    # pack download URLs into _site/data/, which is exactly the data the
    # retirement removed from the page. The retired packs remain readable in
    # archived/packs and registered in archived/archive.json.
    snapshot = {
        "schemaVersion": 1,
        "generatedAt": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "repository": repository,
        "datapacksRetired": True,
        "mods": mods,
    }
    text = json.dumps(snapshot, indent=2, ensure_ascii=False) + "\n"
    write_atomically(out, text)
    print(
        f"build_site_data: wrote {out} "
        f"({len(mods)} mods; datapacks retired, no pack data emitted)"
    )
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Write the Pages data snapshot for index.html.")
    parser.add_argument("--out", required=True, help="path of the JSON file to write")
    args = parser.parse_args(argv)

    repository = os.environ.get("GITHUB_REPOSITORY") or DEFAULT_REPOSITORY
    token = os.environ.get("GITHUB_TOKEN") or None
    try:
        return build(args.out, repository, token)
    except BuildError as exc:
        print(f"build_site_data: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
