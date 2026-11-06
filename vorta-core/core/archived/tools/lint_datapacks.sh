#!/usr/bin/env bash
# Lint the repository's Minecraft packs with the locked Spyglass language server.
# No source files are rewritten and no Minecraft server is started.
set -uo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v node >/dev/null 2>&1; then
    echo "ERROR: Node.js 20 or later is required for datapack lint." >&2
    exit 3
fi
if [ ! -f "$ROOT/scripts/datapack_lint/node_modules/@spyglassmc/language-server/package.json" ]; then
    echo "ERROR: locked lint dependencies are missing; run npm ci --ignore-scripts --no-audit --no-fund in scripts/datapack_lint first." >&2
    exit 3
fi

node "$ROOT/scripts/datapack_lint/lint.mjs" "$@"
status=$?
# Advisory mode downgrades actual diagnostics only. Missing dependencies,
# timeouts, partial scans and other infrastructure failures always fail.
if [ "${LINT_WARN_ONLY:-0}" = 1 ] && [ "$status" -eq 2 ]; then
    echo "LINT_WARN_ONLY=1: diagnostic errors are advisory for this run."
    exit 0
fi
exit "$status"
