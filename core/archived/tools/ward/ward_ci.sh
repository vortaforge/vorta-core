#!/usr/bin/env bash
# =============================================================================
# WARNING - THIS SCRIPT STARTS A MINECRAFT SERVER.
#
# This repository normally never starts, connects to or tests against a
# Minecraft server (see docs/MAINTAINER_GUIDE.md). The ONLY exception is this script, which
# is meant to run inside the isolated GitHub Actions job
# .github/workflows/ward.yml. It uses mcward (Ward) to run datapack tests on a
# throw-away Fabric server that is
#   * bound to 127.0.0.1 only, with the whitelist on, enforced and empty,
#   * verified loopback-only by scripts/ward_guard.py before any test runs,
#   * firewalled on the game port, and
#   * stopped and deleted afterwards, even when a step fails.
#
# NEVER run it on a developer machine, a production host or next to a real
# world. It refuses to run outside GitHub Actions unless
# WARD_ALLOW_LOCAL_SERVER=yes-start-a-minecraft-server is set explicitly.
# =============================================================================
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GUARD="python3 ${REPO_ROOT}/scripts/ward_guard.py"
MC_VERSION="${WARD_MC_VERSION:-}"
MCWARD_VERSION="${MCWARD_VERSION:-1.4.0}"

log()  { printf '[ward-ci] %s\n' "$*"; }
fail() { printf '::error title=Ward CI::%s\n' "$*"; STATUS=1; }
STATUS=0

# --- guards ------------------------------------------------------------------
if [ "${GITHUB_ACTIONS:-}" != "true" ] && [ "${WARD_ALLOW_LOCAL_SERVER:-}" != "yes-start-a-minecraft-server" ]; then
    echo "Refusing to start a Minecraft server outside GitHub Actions (see the header of this file)." >&2
    exit 2
fi
if [ -z "$MC_VERSION" ]; then
    echo "WARD_MC_VERSION is not set (Minecraft version to test on, e.g. 26.3)." >&2
    exit 2
fi

# A private cache keeps every download and the server directory in one place
# that cleanup can delete wholesale.
WORK_DIR="$(mktemp -d "${RUNNER_TEMP:-/tmp}/ward-XXXXXX")"
export XDG_CACHE_HOME="$WORK_DIR/cache"
ENV_DIR="$XDG_CACHE_HOME/mcward/environments/$MC_VERSION"
DAEMON_FLAG="-Dward.daemon=$ENV_DIR/ward.port"
FIREWALL_RULES=()

# --- cleanup (always runs) ---------------------------------------------------
cleanup() {
    local rc=$?
    set +e
    log "cleanup: stopping the server and removing everything it created"
    mcward stop --all >/dev/null 2>&1
    # Match this run's exact daemon flag (it contains the unique work directory),
    # never a loose pattern that could hit an unrelated process.
    pkill -f -- "$DAEMON_FLAG" 2>/dev/null
    sleep 1
    pkill -9 -f -- "$DAEMON_FLAG" 2>/dev/null
    for rule in "${FIREWALL_RULES[@]:-}"; do
        [ -n "$rule" ] && sudo -n ${rule/ -I / -D } 2>/dev/null
    done
    rm -rf "$WORK_DIR"
    if pgrep -f -- "$DAEMON_FLAG" >/dev/null 2>&1; then
        fail "cleanup: a Ward server process is still running"
        rc=1
    elif [ -e "$WORK_DIR" ]; then
        fail "cleanup: $WORK_DIR was not removed"
        rc=1
    else
        log "cleanup: no server process left, $WORK_DIR removed"
    fi
    exit "$rc"
}
trap cleanup EXIT
trap 'exit 130' INT TERM

# --- which packs have tests --------------------------------------------------
cd "$REPO_ROOT" || exit 1
mapfile -t PACKS < <($GUARD discover "$REPO_ROOT")
if [ "${#PACKS[@]}" -eq 0 ] && [ "${WARD_ALLOW_NO_TESTS:-}" != "yes" ]; then
    fail "No datapack contains Ward tests (data/<namespace>/test/**.mcfunction). A required check must test something; set WARD_ALLOW_NO_TESTS=yes only to bypass it knowingly."
    exit 1
fi
if [ "${#PACKS[@]}" -eq 0 ]; then
    log "no Ward tests found and WARD_ALLOW_NO_TESTS=yes: nothing to run, server is not started"
    exit 0
fi
log "packs with Ward tests: ${PACKS[*]}"

# --- install (the only step that needs the network for Minecraft assets) -----
log "installing Minecraft $MC_VERSION environment (downloads Fabric, Fabric API, Ward and a JRE)"
mcward install "$MC_VERSION" || { fail "mcward install failed"; exit 1; }
[ -f "$ENV_DIR/server.jar" ] || { fail "expected server directory $ENV_DIR was not created"; exit 1; }

# --- lock the server down BEFORE it starts -----------------------------------
$GUARD seed "$ENV_DIR" || { fail "could not seed the locked server.properties"; exit 1; }

if command -v iptables >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
    for tool in iptables ip6tables; do
        command -v "$tool" >/dev/null 2>&1 || continue
        rule="$tool -I INPUT 1 ! -i lo -p tcp --dport 25565 -j DROP"
        if sudo -n $rule 2>/dev/null; then
            FIREWALL_RULES+=("$rule")
            log "firewall: inbound TCP 25565 dropped on non-loopback interfaces ($tool)"
        else
            log "WARNING: could not add the $tool rule; relying on the loopback bind and the verification below"
        fi
    done
else
    log "WARNING: no iptables/sudo; relying on the loopback bind and the verification below"
fi

# --- start, prove it is unreachable, test ------------------------------------
log "starting the test server (127.0.0.1 only, whitelist enforced)"
mcward start "$MC_VERSION" || { fail "mcward start failed (see $ENV_DIR/ward.log)"; tail -n 50 "$ENV_DIR/ward.log" 2>/dev/null; exit 1; }

$GUARD verify "$ENV_DIR" || { fail "the server is NOT provably loopback-only: aborting before any test"; exit 1; }

PACK_ARGS=()
for pack in "${PACKS[@]}"; do PACK_ARGS+=(-p "$pack"); done
log "running tests"
mcward test --version "$MC_VERSION" --reporter github "${PACK_ARGS[@]}"
TEST_RC=$?
[ "$TEST_RC" -eq 0 ] || fail "mcward test exited with code $TEST_RC"

# The listener set must not have changed while tests were running.
$GUARD verify "$ENV_DIR" || fail "the server was no longer provably loopback-only after the tests"

[ "$STATUS" -eq 0 ] && log "OK" || log "FAILED"
exit "$STATUS"
