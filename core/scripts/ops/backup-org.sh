#!/usr/bin/env bash
# backup-org.sh
# GitHub organization backup: git (bare) + wiki + issues/PRs/releases/labels
# + Actions/Dependabot/security metadata + team membership/repo access
# + repo topics/languages + optional plain source clones
# + org metadata -> archive (.tar.gz by default, optional 7z/gpg encryption).
#
# Usage:
#   bash scripts/backup-org.sh              # full backup
#   bash scripts/backup-org.sh --dry-run    # show what would run, change nothing
#   bash scripts/backup-org.sh --verify-only ARCHIVE
#                                           # verify an existing archive only
#
# Settings (override with environment variables):
#   ORG=vortaforge  BACKUP_DIR=~/backup/ORG  OUT_DIR=~/backup-out
#   ENCRYPT=none|7z|gpg  INCLUDE_SOURCE=1|0    WITH_HOOKS=0|1
#   KEEP=7            PIP_BREAK_SYSTEM=0|1
#   JOBS=4            # parallel `git clone` workers for plain source copies
#   COPY_TO=          # optional rsync destination for the finished archive,
#                     # e.g. /mnt/nas/backups or user@host:/path (needs a
#                     # working `rsync`/`ssh` locally - no cloud API involved)
#
# Token: uses VC_TOKEN or GH_TOKEN if set, otherwise prompts (interactive only).
# ARCHIVE_PASSWORD: passphrase for ENCRYPT=7z/gpg when run unattended (CI, cron
# with no tty); omit it to be prompted interactively as before.
# Keep this script OUTSIDE any git repository folder if you are worried about
# accidentally committing it.
#
# Privacy: before archiving, tokens / URL credentials / webhook secrets /
# query-string secrets (?token=, ?api_key=, ...) / e-mail addresses are
# redacted from config and metadata files (tar.gz, 7z, and gpg alike), and the
# script aborts if a token pattern is still found there afterwards. This also
# covers the new team-membership, topics and languages files automatically,
# since the sanitize step scans every *.json file under org-meta/repo-meta,
# not a fixed list. Git objects and plain source copies are never modified
# (commit authorship has to stay intact for a restore to be meaningful).
#
# Portability: runs on GNU/Linux and on macOS/BSD. Where a GNU-only tool would
# be needed (sha256sum, find -printf) a portable equivalent is used instead.
#
# Interface: every setting can be given either as an environment variable or
# as a command-line flag of the same name; the flag wins. `--help` prints this
# header plus the flag list. `--strict` makes any warning a non-zero exit, so
# CI can tell a complete backup from a partial one.
#
# Verified with: shellcheck -S style scripts/backup-org.sh   (clean)
#                bash scripts/backup-org.sh --dry-run        (no side effects)

set -Eeuo pipefail
umask 077

SCRIPT_VERSION="3.0"

log()  { printf '[%s] %s\n' "$(date +%T)" "$*"; }
# warn() counts what it prints. A backup tool that cannot tell "I got
# everything" from "half the org returned 403" is not much use, so --strict
# turns WARN_COUNT into a non-zero exit instead of asking the reader to scan
# the log for the word WARNING.
WARN_COUNT=0
warn() { WARN_COUNT=$((WARN_COUNT + 1)); printf '[%s] WARNING: %s\n' "$(date +%T)" "$*" >&2; }
# note() is the same output with a different severity: an advisory about a
# choice the caller made deliberately, not something that went wrong. Counting
# those would make `--strict --encrypt none` fail on every single run, which
# would teach people to stop using --strict at all.
note() { printf '[%s] NOTE: %s\n' "$(date +%T)" "$*"; }
die()  { printf '[%s] ERROR: %s\n' "$(date +%T)" "$*" >&2; exit 1; }

# FIX: --help ran `sed -n '2,32p' "$0"`. The header comment had grown to 38
# lines, so the last 7 were silently dropped and the output ended mid-sentence
# ("...found there afterwards. This also" - verified by running --help). Derive
# the range from the file instead: print every leading comment line, stop at
# the first line that is not a comment. Help can no longer drift out of sync.
print_header() {
  awk 'NR == 1 { next } /^#/ { sub(/^# ?/, ""); print; next } { exit }' "$0"
}

usage() {
  print_header
  cat <<'USAGE'

Command-line flags (each overrides the environment variable of the same name):
  --org ORG            Organization to back up            [env ORG]
  --backup-dir DIR     Working directory for the backup   [env BACKUP_DIR]
  --out-dir DIR        Where the archive is written       [env OUT_DIR]
  --encrypt METHOD     none | 7z | gpg                    [env ENCRYPT]
  --keep N             Archives to keep when pruning      [env KEEP]
  --jobs N             Parallel source-clone workers      [env JOBS]
  --copy-to DEST       rsync the finished archive here    [env COPY_TO]
  --with-source        Include plain source checkouts     [env INCLUDE_SOURCE=1]
  --no-source          Skip plain source checkouts        [env INCLUDE_SOURCE=0]
  --with-hooks         Include webhook definitions        [env WITH_HOOKS=1]
  --strict             Exit non-zero if anything was warned about
  --dry-run            Show what would run, change nothing
  --verify-only FILE   Verify an existing archive (and its .sha256) and exit
  --version            Print the script version and exit
  -h, --help           This text

A flag always wins over its environment variable. Everything is still readable
from the environment alone, which is how .github/workflows/backup-org.yml
drives the script.
USAGE
}

# ------------------------------------------------------------------ arguments
DRY_RUN=0
VERIFY_ONLY=""
STRICT=0

# Environment defaults first, so a flag simply overwrites the variable it
# stands for. BACKUP_DIR is deliberately NOT defaulted here: its default is
# derived from ORG, and --org has to be parsed first for that to be right.
ORG="${ORG:-vortaforge}"
OUT_DIR="${OUT_DIR:-$HOME/backup-out}"
ENCRYPT="${ENCRYPT:-gpg}"
# Pinned github-backup release. There is no floating "latest": a backup tool
# with organisation-read access is not something to resolve at run time.
GHBK_VERSION="${GHBK_VERSION:-0.67.0}"
# sha256 of github_backup-0.67.0-py3-none-any.whl, as published on PyPI.
# Refresh both lines together when bumping the version; the install refuses to
# proceed without a hash, so a bare version bump fails loudly instead of
# silently installing unverified code.
GHBK_HASH="${GHBK_HASH:-dc112537678851d698037d07b4fbe3adc00cb3e8f1fc1f9a1c1ef8b3f1494086}"
GHBK_VENV="${GHBK_VENV:-$HOME/.venvs/github-backup}"
INCLUDE_SOURCE="${INCLUDE_SOURCE:-1}"
WITH_HOOKS="${WITH_HOOKS:-0}"
KEEP="${KEEP:-7}"
PIP_BREAK_SYSTEM="${PIP_BREAK_SYSTEM:-0}"
JOBS="${JOBS:-4}"
COPY_TO="${COPY_TO:-}"

need_arg() { # need_arg <flag> <remaining-arg-count>
  [ "$2" -ge 2 ] || die "$1 needs a value"
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run)      DRY_RUN=1; shift ;;
    --strict)       STRICT=1; shift ;;
    --with-source)  INCLUDE_SOURCE=1; shift ;;
    --no-source)    INCLUDE_SOURCE=0; shift ;;
    --with-hooks)   WITH_HOOKS=1; shift ;;
    --verify-only)  need_arg "$1" $#; VERIFY_ONLY="$2"; shift 2 ;;
    --org)          need_arg "$1" $#; ORG="$2"; shift 2 ;;
    --backup-dir)   need_arg "$1" $#; BACKUP_DIR="$2"; shift 2 ;;
    --out-dir)      need_arg "$1" $#; OUT_DIR="$2"; shift 2 ;;
    --encrypt)      need_arg "$1" $#; ENCRYPT="$2"; shift 2 ;;
    --keep)         need_arg "$1" $#; KEEP="$2"; shift 2 ;;
    --jobs)         need_arg "$1" $#; JOBS="$2"; shift 2 ;;
    --copy-to)      need_arg "$1" $#; COPY_TO="$2"; shift 2 ;;
    --version)      printf 'backup-org.sh %s\n' "$SCRIPT_VERSION"; exit 0 ;;
    -h|--help)      usage; exit 0 ;;
    *) printf 'unknown option: %s\n' "$1" >&2
       printf 'try: bash %s --help\n' "$0" >&2
       exit 2 ;;
  esac
done

BACKUP_DIR="${BACKUP_DIR:-$HOME/backup/$ORG}"
DATE="$(date +%F)"
RUN_STAMP="$(date +%Y%m%d-%H%M%S)"

LOG_FILE="${LOG_FILE:-$OUT_DIR/backup-$RUN_STAMP.log}"

# FIX: `set -e` alone reports no context. Report the failing line instead of
# leaving the user with a bare non-zero exit.
on_err() {
  local rc=$? line=${1:-?}
  warn "command failed (exit $rc) at line $line - see $LOG_FILE"
}
trap 'on_err $LINENO' ERR

case "$ENCRYPT" in 7z|gpg|none) ;; *) die "ENCRYPT must be 7z, gpg, or none" ;; esac
# An unencrypted archive is only defensible while it stays on this machine. The
# workflow sets UPLOAD_ARCHIVE=1 because the artifact leaves the runner, so the
# two states are mutually exclusive by construction rather than by convention.
if [ "$ENCRYPT" = none ] && [ "${UPLOAD_ARCHIVE:-0}" = 1 ]; then
  die "ENCRYPT=none refused: UPLOAD_ARCHIVE=1 means the archive leaves this machine. Use ENCRYPT=gpg (or 7z) with ARCHIVE_PASSWORD."
fi

case "$JOBS" in
  ''|*[!0-9]*) die "JOBS must be a positive integer, got: $JOBS" ;;
esac
[ "$JOBS" -ge 1 ] || die "JOBS must be >= 1"

# FIX: KEEP=0 used to make `tail -n +1` emit every archive, i.e. the pruning
# step deleted the entire history including the archive just created.
case "$KEEP" in
  ''|*[!0-9]*) die "KEEP must be a non-negative integer, got: $KEEP" ;;
esac
if [ "$KEEP" -lt 1 ]; then
  die "KEEP must be >= 1 (KEEP=0 would delete every archive, including this run's)"
fi

# ------------------------------------------------------------ portability glue
# sha256sum is GNU-only; macOS ships `shasum`.
hash_archive() {
  if command -v sha256sum >/dev/null 2>&1; then
    (cd "$(dirname "$1")" && sha256sum "$(basename "$1")" > "$(basename "$1").sha256")
  elif command -v shasum >/dev/null 2>&1; then
    (cd "$(dirname "$1")" && shasum -a 256 "$(basename "$1")" > "$(basename "$1").sha256")
  else
    warn "neither sha256sum nor shasum found; no checksum written"
    return 1
  fi
}

# `find -printf` is GNU-only. Sort by mtime portably via `stat`.
mtime_of() {
  if stat -c %Y "$1" >/dev/null 2>&1; then stat -c %Y "$1"
  else stat -f %m "$1"; fi
}

run() { # run <cmd...> - honours --dry-run
  if [ "$DRY_RUN" = 1 ]; then log "[dry-run] $*"; return 0; fi
  "$@"
}

# ------------------------------------------------------------- verify-only mode
if [ -n "$VERIFY_ONLY" ]; then
  [ -f "$VERIFY_ONLY" ] || die "archive not found: $VERIFY_ONLY"
  log "Verifying $VERIFY_ONLY"
  case "$VERIFY_ONLY" in
    *.7z)
      command -v 7z >/dev/null || die "7z not installed, cannot verify a .7z archive"
      # ARCHIVE_PASSWORD is accepted here for the same reason it exists on the
      # create path: an unattended `--verify-only` (CI, cron) has no tty, and
      # under `set -e` a failed `read` killed the script with no explanation.
      if [ -n "${ARCHIVE_PASSWORD:-}" ]; then
        PW1="$ARCHIVE_PASSWORD"
      else
        [ -t 0 ] || die "an encrypted .7z needs ARCHIVE_PASSWORD set, or an interactive terminal"
        read -rsp "Archive password: " PW1; echo
      fi
      7z t -p"$PW1" -bd "$VERIFY_ONLY" >/dev/null || die "archive test failed"
      ;;
    *.gpg)
      command -v gpg >/dev/null || die "gpg not installed, cannot verify a .gpg archive"
      TMPV="$(mktemp -d)"; trap 'rm -rf "$TMPV"' EXIT
      gpg --batch --yes -d -o "$TMPV/decrypted.tar.gz" "$VERIFY_ONLY" \
        || die "gpg decryption failed (wrong passphrase or corrupt archive)"
      tar -tzf "$TMPV/decrypted.tar.gz" >/dev/null || die "archive verification failed"
      ;;
    *)
      tar -tzf "$VERIFY_ONLY" >/dev/null || die "archive verification failed"
      ;;
  esac
  # Checksum first. `tar -tzf`/`7z t` only prove the container is readable, so
  # a truncated download that still parses would pass. The sidecar written by
  # hash_archive() is verified when it sits next to the archive; its absence is
  # a warning, not an error (it may simply not have been copied along).
  if [ -f "$VERIFY_ONLY.sha256" ]; then
    if command -v sha256sum >/dev/null 2>&1; then
      (cd "$(dirname "$VERIFY_ONLY")" && sha256sum -c "$(basename "$VERIFY_ONLY").sha256") \
        || die "SHA-256 mismatch - the archive is corrupt or was modified"
    elif command -v shasum >/dev/null 2>&1; then
      (cd "$(dirname "$VERIFY_ONLY")" && shasum -a 256 -c "$(basename "$VERIFY_ONLY").sha256") \
        || die "SHA-256 mismatch - the archive is corrupt or was modified"
    else
      warn "no sha256sum/shasum available; the .sha256 sidecar was not checked"
    fi
    log "SHA-256 sidecar verified"
  else
    warn "no $(basename "$VERIFY_ONLY").sha256 next to the archive; checksum not verified"
  fi

  # Report what is inside, so a silently truncated backup is visible.
  [ -n "${TMPV:-}" ] || { TMPV="$(mktemp -d)"; trap 'rm -rf "$TMPV"' EXIT; }
  if [ "${VERIFY_ONLY##*.}" = "7z" ]; then
    # FIX: this listing ran WITHOUT the password, but archives are created with
    # `-mhe=on` (header encryption), so 7z could not read the file list and
    # every .7z verification silently reported "0 entries". PW1 is now kept
    # until after the listing instead of being unset right after `7z t`.
    7z l -ba -p"$PW1" "$VERIFY_ONLY" | awk '{print $NF}' > "$TMPV/list" 2>/dev/null || true
    unset PW1
  elif [ "${VERIFY_ONLY##*.}" = "gpg" ]; then
    tar -tzf "$TMPV/decrypted.tar.gz" > "$TMPV/list"
  else
    tar -tzf "$VERIFY_ONLY" > "$TMPV/list"
  fi
  # FIX: this was `grep -c ... || echo 0`. grep -c already prints "0" and then
  # exits 1, so `|| echo 0` appended a SECOND zero and nrepos became the
  # two-line string "0\n0" - which made the very next `[ "$nrepos" -gt 0 ]`
  # fail with "integer expression expected". That is exactly the case
  # --verify-only exists for: an archive that turned out to hold no repos.
  nrepos="$(grep -c '/repositories/[^/]*/repository/HEAD$' "$TMPV/list" 2>/dev/null)" || nrepos=0
  nfiles="$(wc -l < "$TMPV/list" | tr -d ' ')"
  log "Archive OK: ${nfiles:-0} entries, ${nrepos:-0} bare git repositories"
  [ "${nrepos:-0}" -gt 0 ] || warn "no bare repositories found in the archive"
  if [ "$STRICT" = 1 ] && [ "$WARN_COUNT" -gt 0 ]; then
    die "$WARN_COUNT warning(s) during verification and --strict was given"
  fi
  exit 0
fi

# ---------------------------------------------------------------------- token
TOKEN="${VC_TOKEN:-${GH_TOKEN:-}}"
TOKEN_FILE=""
cleanup() {
  [ -n "$TOKEN_FILE" ] && rm -f -- "$TOKEN_FILE"
  unset TOKEN VC_TOKEN GH_TOKEN PW1 PW2 ARCHIVE_PASSWORD 2>/dev/null || true
}
trap cleanup EXIT

if [ -z "$TOKEN" ]; then
  # FIX: under `set -e`, `read -rsp` with no terminal returns non-zero and killed
  # the script with no explanation. Detect that case and say what to do.
  if [ ! -t 0 ]; then
    die "no token available and stdin is not a terminal - set VC_TOKEN or GH_TOKEN"
  fi
  read -rsp "GitHub token (input is hidden): " TOKEN
  echo
fi
[ -n "$TOKEN" ] || die "token is empty"

# ---------------------------------------------------------------------- tools
command -v git >/dev/null || die "git not found"
command -v perl >/dev/null || warn "perl not found - credential redaction will be skipped"
# curl is only strictly needed when `gh` is absent (api_get_raw falls back to
# it), but the token pre-flight below always uses it, so require it outright
# rather than discovering the gap an hour into a backup.
command -v curl >/dev/null || die "curl not found - required for the GitHub API calls"

# Fail fast on a bad, expired or under-scoped token. Previously the first sign
# of trouble was github-backup failing part-way through - after a pip install
# and possibly after cloning repositories - with an error naming the tool
# rather than the credential. One cheap API call up front turns that into an
# immediate, accurate message. Skipped under --dry-run, which must not touch
# the network at all.
if [ "$DRY_RUN" != 1 ]; then
  auth_status="$(curl -sS -o /dev/null -w '%{http_code}' --max-time 30 \
    -H "Authorization: Bearer $TOKEN" \
    -H 'Accept: application/vnd.github+json' \
    "https://api.github.com/orgs/$ORG" 2>/dev/null)" || auth_status="000"
  case "$auth_status" in
    200) log "Token accepted; organization '$ORG' is readable." ;;
    401) die "GitHub rejected the token (HTTP 401): it is empty, expired or revoked." ;;
    403) die "GitHub refused the request (HTTP 403): the token is valid but cannot see '$ORG', or is rate-limited / SSO-gated." ;;
    404) die "Organization '$ORG' is not visible to this token (HTTP 404). Check --org and that the token has organization read access." ;;
    000) die "could not reach api.github.com - check the network or proxy settings." ;;
    *)   die "unexpected response from api.github.com/orgs/$ORG (HTTP $auth_status)" ;;
  esac
fi

if ! command -v github-backup >/dev/null 2>&1; then
  log "installing github-backup ${GHBK_VERSION}"
  if [ "$DRY_RUN" = 1 ]; then
    log "[dry-run] python3 -m venv $GHBK_VENV && $GHBK_VENV/bin/pip install github-backup==${GHBK_VERSION}"
  else
    # Pinned, isolated, and installed with no credential in the environment.
    #
    # Three separate problems, all removed here:
    #   1. `pip install github-backup` resolved whatever was newest at run
    #      time. A compromised or typosquatted release would run its setup
    #      code as whoever invoked this script.
    #   2. That install ran with VC_TOKEN/GH_TOKEN still exported, so setup
    #      code could read an organisation-read credential out of the
    #      environment. `env -u` removes it for the duration of the install;
    #      the token is only reintroduced for the github-backup call itself.
    #   3. It installed into the system interpreter (or needed
    #      --break-system-packages), mixing a backup tool into the distro's
    #      Python. It now goes into a private venv.
    #
    # GHBK_HASH pins the artefact and is required: there is no path through
    # this block that installs an unverified release.
    python3 -m venv "$GHBK_VENV" || die "could not create a venv at $GHBK_VENV"
    # pip --require-hashes makes pip itself verify the artefact's sha256
    # against this file before running any of its code, which is the part
    # `pip install "pkg==version"` alone does not give you: the version pins
    # *which* release, the hash pins *those exact bytes*.
    reqs="$(mktemp "${TMPDIR:-/tmp}/ghbk-req.XXXXXXXX")"
    # shellcheck disable=SC2064
    trap "rm -f -- '$reqs'" RETURN 2>/dev/null || true
    printf 'github-backup==%s --hash=sha256:%s\n' "$GHBK_VERSION" "$GHBK_HASH" > "$reqs"
    if ! env -u GH_TOKEN -u VC_TOKEN -u GITHUB_TOKEN \
        "$GHBK_VENV/bin/pip" install --quiet --disable-pip-version-check \
        --require-hashes -r "$reqs" ; then
      rm -f -- "$reqs"
      die "github-backup ${GHBK_VERSION} failed hash verification or could not be installed"
    fi
    rm -f -- "$reqs"
    log "github-backup ${GHBK_VERSION} installed from a hash-verified artefact"
    PATH="$GHBK_VENV/bin:$PATH"
  fi
fi

# The availability check must not run under --dry-run. A dry run deliberately
# skips the install above, so requiring the binary here made every dry run on a
# clean machine -- including a fresh ubuntu-latest runner, which has no
# github-backup -- fail with "github-backup is not on PATH" immediately after
# printing what it would install. A dry run's job is to prove the plan, not to
# prove a dependency that it is explicitly not installing.
if [ "$DRY_RUN" = 1 ]; then
  if command -v github-backup >/dev/null 2>&1; then
    log "github-backup present: $(github-backup --version 2>/dev/null | head -1 || echo 'present')"
  else
    log "[dry-run] github-backup is not installed; a real run would install ${GHBK_VERSION}"
  fi
else
  command -v github-backup >/dev/null 2>&1 \
    || die "github-backup is not on PATH; set GHBK_VENV to the venv that has it, or let this script install it"
fi

mkdir -p "$BACKUP_DIR" "$OUT_DIR" "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log "Starting backup: $ORG -> $BACKUP_DIR  (dry-run=$DRY_RUN)"

# ------------------------------------------- pick supported CLI flags
# Flag names can vary between versions; unsupported ones are skipped.
HELP="$(github-backup --help 2>&1 || true)"
WANT=(--repositories --wikis --issues --issue-comments --issue-events
      --pulls --pull-comments --pull-commits --pull-details
      --labels --milestones --releases --assets)
if [ "$WITH_HOOKS" = 1 ]; then WANT+=(--hooks); fi
FLAGS=()
for f in "${WANT[@]}"; do
  if grep -q -- "$f" <<<"$HELP"; then
    FLAGS+=("$f")
  else
    warn "$f is not available in this github-backup version, skipped"
  fi
done

# --------------------------------------------------------------- backup
# Keep the token out of argv: a command-line token is readable by every local
# user via `ps`/`/proc/<pid>/cmdline` for the whole (long) backup run. Newer
# github-backup versions accept a file:// path for -t; use a 0600 temp file
# (umask 077 above) removed by the EXIT trap. Older versions fall back to argv.
TOKEN_ARG="$TOKEN"
if grep -q -- 'file://' <<<"$HELP"; then
  TOKEN_FILE="$(mktemp)"
  printf '%s' "$TOKEN" > "$TOKEN_FILE"
  TOKEN_ARG="file://$TOKEN_FILE"
else
  warn "this github-backup has no file:// token support; the token is passed on the command line (visible in ps)"
fi

run github-backup "$ORG" --organization -t "$TOKEN_ARG" -o "$BACKUP_DIR" \
  --private --fork --bare --incremental "${FLAGS[@]}"

# ------------------------------------------------- API access
# `gh` is preferred, but it is not installed everywhere. Fall back to curl so
# the metadata and the repository-count check still run. (Previously the whole
# metadata section was skipped silently when gh was missing.)
HAVE_GH=0
command -v gh >/dev/null 2>&1 && HAVE_GH=1
API_BASE="https://api.github.com"

api_get_raw() { # api_get_raw <path> -> JSON on stdout, one document PER PAGE; non-zero on error
  local path="$1" sep="?"
  case "$path" in *\?*) sep="&" ;; esac
  if [ "$HAVE_GH" = 1 ]; then
    GH_TOKEN="$TOKEN" gh api --paginate "$path" 2>/dev/null
    return $?
  fi
  local page=1 resp n
  while :; do
    resp="$(curl -sS --max-time 60 -H "Authorization: Bearer $TOKEN" \
      -H 'Accept: application/vnd.github+json' \
      "$API_BASE$path${sep}per_page=100&page=$page")" || return 1
    printf '%s' "$resp"
    n="$(printf '%s' "$resp" | python3 -c \
      'import sys,json
try: d=json.load(sys.stdin)
except Exception: d=None
print(len(d) if isinstance(d,list) else 0)' 2>/dev/null || echo 0)"
    [ "${n:-0}" -lt 100 ] && return 0
    page=$((page + 1))
    printf '\n'
  done
}


# FIX: `gh api --paginate` (and the curl fallback) emit one JSON document per
# page, back to back. The saved files were therefore not valid JSON as soon as
# a listing spanned more than one page (e.g. actions-runs-recent.json was 9
# concatenated documents), and every python json.load() consumer of api_get
# (REPO_LIST, TEAM_SLUGS, ...) failed silently on orgs with >100 items. Merge
# the pages into ONE valid document here, so all callers get the same shape.
# Fail-soft: if the pages cannot be merged unambiguously, the raw text is
# passed through unchanged rather than dropping data.
api_get() { # api_get <path> -> a single valid JSON document on stdout
  local tmp rc=0
  tmp="$(mktemp)"
  api_get_raw "$@" > "$tmp" || rc=$?
  if [ "$rc" -eq 0 ]; then
    python3 - "$tmp" <<'PY' || cat "$tmp"
import json, sys
raw = open(sys.argv[1], encoding="utf-8").read()
dec, i, docs = json.JSONDecoder(), 0, []
while True:
    while i < len(raw) and raw[i].isspace():
        i += 1
    if i >= len(raw):
        break
    obj, i = dec.raw_decode(raw, i)
    docs.append(obj)
if len(docs) <= 1:
    sys.stdout.write(raw)
elif all(isinstance(d, list) for d in docs):
    json.dump([x for d in docs for x in d], sys.stdout)
elif all(isinstance(d, dict) for d in docs):
    merged = dict(docs[0])
    keys = [k for k, v in docs[0].items() if isinstance(v, list)]
    if not keys:
        sys.stdout.write(raw)
        sys.exit(0)
    for k in keys:
        merged[k] = [x for d in docs for x in d.get(k, [])]
    json.dump(merged, sys.stdout)
else:
    sys.stdout.write(raw)
PY
  fi
  rm -f "$tmp"
  return "$rc"
}

# ------------------------------------------------- org-level metadata
# FIX: --dry-run is documented as "show what would run, change nothing", but
# this loop (and the repository-count check below it) ran unconditionally, so a
# dry run really did call the API and write org-meta/*.json into BACKUP_DIR.
# Both are now guarded, matching the save() helper further down, which already
# honoured DRY_RUN.
if [ "$DRY_RUN" = 1 ]; then
  log "[dry-run] would fetch org-meta/{teams,members,rulesets}.json"
else
  mkdir -p "$BACKUP_DIR/org-meta"
  for ep in teams members rulesets; do
    if api_get "/orgs/$ORG/$ep" > "$BACKUP_DIR/org-meta/$ep.json.tmp" 2>/dev/null; then
      mv "$BACKUP_DIR/org-meta/$ep.json.tmp" "$BACKUP_DIR/org-meta/$ep.json"
      log "saved org-meta/$ep.json"
    else
      rm -f "$BACKUP_DIR/org-meta/$ep.json.tmp"
      warn "could not fetch $ep (missing permission?)"
    fi
  done
fi

# FIX: the old check was
#     gh api --jq '.public_repos + .total_private_repos'
# `total_private_repos` is only populated when the token has the scope for it;
# when it is null, jq errors, `|| true` swallowed that, and the whole
# repository-count sanity check silently never ran. Read the fields separately
# with a null default, and say loudly when the check cannot run.
EXPECTED=""
if [ "$DRY_RUN" = 1 ]; then
  log "[dry-run] would verify the repository count against the org"
else
  EXPECTED="$(api_get "/orgs/$ORG" 2>/dev/null | python3 -c \
  'import sys,json
try:
    d=json.load(sys.stdin)
    print((d.get("public_repos") or 0) + (d.get("total_private_repos") or 0))
except Exception:
    pass' 2>/dev/null || true)"
fi

# FIX (pre-existing, verified against the pre-fix revision): on a first run
# $BACKUP_DIR/repositories does not exist yet, so `find` exits 1, and under
# `set -Eeuo pipefail` that status propagates out of the pipeline and aborts
# the script. `2>/dev/null` hid the message but not the status. The effect was
# that --dry-run - the mode you reach for precisely BEFORE a first real backup -
# died here every single time, printing only "command failed (exit 1) at line
# 346". Guard the path rather than leaning on the shell to swallow the status.
ACTUAL=0
if [ -d "$BACKUP_DIR/repositories" ]; then
  ACTUAL="$(find "$BACKUP_DIR/repositories" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
fi
if [ "$DRY_RUN" = 1 ]; then
  : # nothing to compare against; the run is a rehearsal
elif [ -z "$EXPECTED" ]; then
  warn "could not read the org repository count - skipping the completeness check"
elif [ "$EXPECTED" != "$ACTUAL" ]; then
  warn "the org reports $EXPECTED repositories but the backup has $ACTUAL folders. Check for missing ones."
else
  log "Repository count verified: $ACTUAL"
fi

# ------------------------------------------- extended metadata
# Org-level: outside collaborators, webhooks, Actions variables / secret NAMES
# (never values), permissions, GitHub App installations, pending invitations,
# security managers, and the org's own settings.
# Repo-level: collaborators, webhooks, deploy keys (public part), environments,
# variables / secret names, Pages, rulesets, default-branch protection, plus
# Actions workflows, recent run history and open security alerts.
# Note: the Actions secrets endpoint never returns secret values, only names
# and timestamps, so storing the raw response is safe.
mkdir -p "$BACKUP_DIR/repo-meta"
save() { # save <outfile> <api path>; a missing permission is not fatal
  local out="$1" path="$2"
  if [ "$DRY_RUN" = 1 ]; then log "[dry-run] save $out <- $path"; return 0; fi
  if api_get "$path" > "$out.tmp" 2>/dev/null; then
    mv "$out.tmp" "$out"
  else
    rm -f "$out.tmp"
    log "note: $path not available (permission or feature missing)"
  fi
}

save "$BACKUP_DIR/org-meta/org.json"                    "/orgs/$ORG"
save "$BACKUP_DIR/org-meta/outside-collaborators.json"  "/orgs/$ORG/outside_collaborators"
save "$BACKUP_DIR/org-meta/hooks.json"                  "/orgs/$ORG/hooks"
save "$BACKUP_DIR/org-meta/actions-variables.json"      "/orgs/$ORG/actions/variables"
save "$BACKUP_DIR/org-meta/actions-secret-names.json"   "/orgs/$ORG/actions/secrets"
save "$BACKUP_DIR/org-meta/actions-permissions.json"    "/orgs/$ORG/actions/permissions"
save "$BACKUP_DIR/org-meta/installations.json"          "/orgs/$ORG/installations"
save "$BACKUP_DIR/org-meta/invitations.json"            "/orgs/$ORG/invitations"
# NEW: security posture, so a restore can reproduce it
save "$BACKUP_DIR/org-meta/security-managers.json"      "/orgs/$ORG/security-managers"
save "$BACKUP_DIR/org-meta/dependabot-alerts.json"      "/orgs/$ORG/dependabot/alerts"
save "$BACKUP_DIR/org-meta/secret-scanning-alerts.json" "/orgs/$ORG/secret-scanning/alerts"

# NEW: per-team membership and repository access, so who-can-access-what can
# be restored, not just the bare team list. Team member objects only carry
# login/id/avatar_url (no e-mail or real name), so this adds no new PII; the
# sanitize step below still runs over these files like every other .json.
# FIX: org-meta/teams.json is absent whenever the fetch was skipped (--dry-run)
# or failed for lack of a permission. `< missing-file` is a redirection error
# raised by the shell itself, so the trailing `2>/dev/null || true` never got a
# chance to absorb it and the run aborted here.
TEAM_SLUGS=""
if [ -f "$BACKUP_DIR/org-meta/teams.json" ]; then
  TEAM_SLUGS="$(python3 -c \
    'import sys,json
try:
    for t in json.load(sys.stdin): print(t["slug"])
except Exception: pass' < "$BACKUP_DIR/org-meta/teams.json" 2>/dev/null || true)"
fi
if [ -n "$TEAM_SLUGS" ]; then
  mkdir -p "$BACKUP_DIR/org-meta/teams"
  while IFS= read -r slug; do
    [ -n "$slug" ] || continue
    save "$BACKUP_DIR/org-meta/teams/$slug-members.json" "/orgs/$ORG/teams/$slug/members"
    save "$BACKUP_DIR/org-meta/teams/$slug-repos.json"   "/orgs/$ORG/teams/$slug/repos"
  done <<< "$TEAM_SLUGS"
fi

REPO_LIST="$(api_get "/orgs/$ORG/repos" 2>/dev/null | python3 -c \
  'import sys,json
try:
    for r in json.load(sys.stdin): print(r["name"])
except Exception: pass' 2>/dev/null || true)"
if [ -z "$REPO_LIST" ]; then
  warn "could not list repositories for extended metadata"
else
  while IFS= read -r repo; do
    [ -n "$repo" ] || continue
    d="$BACKUP_DIR/repo-meta/$repo"; mkdir -p "$d"
    save "$d/repo.json"                 "/repos/$ORG/$repo"
    save "$d/collaborators.json"        "/repos/$ORG/$repo/collaborators"
    save "$d/hooks.json"                "/repos/$ORG/$repo/hooks"
    save "$d/deploy-keys.json"          "/repos/$ORG/$repo/keys"
    save "$d/environments.json"         "/repos/$ORG/$repo/environments"
    # FIX: environments.json only names the protection rule types; the custom
    # deployment-branch policies (which refs may deploy) live in a sub-endpoint.
    if [ "$DRY_RUN" != 1 ] && [ -f "$d/environments.json" ]; then
      ENV_NAMES="$(python3 -c \
        'import sys,json,urllib.parse
try:
    for e in json.load(sys.stdin).get("environments", []): print(urllib.parse.quote(e["name"], safe=""))
except Exception: pass' < "$d/environments.json" 2>/dev/null || true)"
      if [ -n "$ENV_NAMES" ]; then
        mkdir -p "$d/environments-detail"
        while IFS= read -r en; do
          [ -n "$en" ] || continue
          save "$d/environments-detail/$en-branch-policies.json" \
               "/repos/$ORG/$repo/environments/$en/deployment-branch-policies"
        done <<< "$ENV_NAMES"
      fi
    fi
    save "$d/actions-variables.json"    "/repos/$ORG/$repo/actions/variables"
    save "$d/actions-secret-names.json" "/repos/$ORG/$repo/actions/secrets"
    save "$d/pages.json"                "/repos/$ORG/$repo/pages"
    save "$d/rulesets.json"             "/repos/$ORG/$repo/rulesets"
    # FIX: the ruleset LIST only has id/name/enforcement; the rules, conditions
    # and bypass actors needed for a restore are in the per-ruleset endpoint.
    if [ "$DRY_RUN" != 1 ] && [ -f "$d/rulesets.json" ]; then
      RS_IDS="$(python3 -c \
        'import sys,json
try:
    for r in json.load(sys.stdin): print(r["id"])
except Exception: pass' < "$d/rulesets.json" 2>/dev/null || true)"
      if [ -n "$RS_IDS" ]; then
        mkdir -p "$d/rulesets-detail"
        while IFS= read -r rid; do
          [ -n "$rid" ] || continue
          save "$d/rulesets-detail/$rid.json" "/repos/$ORG/$repo/rulesets/$rid"
        done <<< "$RS_IDS"
      fi
    fi
    # NEW: Actions definitions and recent history (metadata only, no logs)
    save "$d/actions-workflows.json"    "/repos/$ORG/$repo/actions/workflows"
    save "$d/actions-runs-recent.json"  "/repos/$ORG/$repo/actions/runs?per_page=100"
    # NEW: open security alerts, so they survive even if the repo is deleted
    save "$d/dependabot-alerts.json"    "/repos/$ORG/$repo/dependabot/alerts?state=open"
    save "$d/secret-scanning-alerts.json" "/repos/$ORG/$repo/secret-scanning/alerts?state=open"
    # NEW: community health snapshot
    save "$d/community-profile.json"    "/repos/$ORG/$repo/community/profile"
    # NEW: topics and language breakdown - plain repo metadata, no PII
    save "$d/topics.json"               "/repos/$ORG/$repo/topics"
    save "$d/languages.json"            "/repos/$ORG/$repo/languages"
    branch="$(api_get "/repos/$ORG/$repo" 2>/dev/null | python3 -c \
      'import sys,json
try: print(json.load(sys.stdin).get("default_branch") or "")
except Exception: pass' 2>/dev/null || true)"
    [ -z "$branch" ] || save "$d/branch-protection.json" "/repos/$ORG/$repo/branches/$branch/protection"
    rmdir "$d/rulesets-detail" "$d/environments-detail" 2>/dev/null || true
    rmdir "$d" 2>/dev/null || true
  done <<< "$REPO_LIST"
fi

# ------------------------------------ integrity check + plain source clones
# NEW: done in parallel (JOBS workers) instead of one repo at a time - on an
# org with many repositories the serial `git clone` loop was the slowest part
# of the whole backup.
process_repo() {
  local r="${1%/}"
  if [ -d "$r/repository" ]; then
    git --git-dir="$r/repository" fsck --no-progress >/dev/null 2>&1 \
      || warn "git fsck failed: $r/repository"
  fi
  rm -rf "$r/source" "$r/wiki-source"
  if [ "$INCLUDE_SOURCE" = 1 ] && [ "$DRY_RUN" != 1 ]; then
    if [ -d "$r/repository" ]; then
      git clone --quiet "$r/repository" "$r/source" 2>/dev/null \
        || warn "could not clone $r/source (empty repository?)"
    fi
    if [ -d "$r/wiki" ]; then
      git clone --quiet "$r/wiki" "$r/wiki-source" 2>/dev/null \
        || warn "could not clone $r/wiki-source (empty wiki?)"
    fi
  fi
}
export -f log warn process_repo
export INCLUDE_SOURCE DRY_RUN

# FIX: same missing-directory class of bug as ACTUAL/want above. `find` on an
# absent $BACKUP_DIR/repositories exits 1 and pipefail aborts the run, so the
# script never reached the archive step on a first-time --dry-run.
shopt -s dotglob nullglob
if [ -d "$BACKUP_DIR/repositories" ]; then
  find "$BACKUP_DIR/repositories" -mindepth 1 -maxdepth 1 -type d -print0 \
    | xargs -0 -P "$JOBS" -I{} bash -c 'process_repo "$@"' _ {}
fi
shopt -u dotglob nullglob

if [ "$INCLUDE_SOURCE" = 1 ]; then
  n=0
  if [ -d "$BACKUP_DIR/repositories" ]; then
    n="$(find "$BACKUP_DIR/repositories" -path '*/source/*' -not -path '*/.git/*' -type f | wc -l | tr -d ' ')"
  fi
  log "Plain source files going into the archive: $n"
  if [ "${n:-0}" -eq 0 ] && [ "$DRY_RUN" != 1 ]; then
    warn "source/ folders are empty, source code will not be in the archive."
  fi
fi

# ----------------------------------------------------------- sanitize
# Runs on the folder BEFORE archiving, so tar.gz and 7z are both covered.
# Touches only config/metadata files; never git objects or source copies.
TOKEN_RE='(gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{40,})'
sanitize_dir() {
  if ! command -v perl >/dev/null 2>&1; then
    die "perl is required for credential redaction; install it or abort"
  fi
  local n=0 f
  while IFS= read -r -d '' f; do
    if grep -aEq "$TOKEN_RE|https?://[^/[:space:]@:]+:[^@[:space:]/]+@|\"(secret|token|password|client_secret)\"[[:space:]]*:[[:space:]]*\"[^\"]+\"|hooks\.slack\.com/services|discord(app)?\.com/api/webhooks|[?&](token|key|secret|password|api_key|access_token)=" "$f"; then
      perl -0pi -e '
        s#\b(gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{40,})\b#[REDACTED:token]#g;
        s#(https?://)[^/\s:@]+:[^@\s/]+@#$1\[REDACTED]@#g;
        s#("(?:secret|token|password|client_secret)"\s*:\s*)"[^"]+"#$1"[REDACTED]"#gi;
        s#https://(?:hooks\.slack\.com/services|discord(?:app)?\.com/api/webhooks)/[^\s"\x27]+#[REDACTED:webhook]#g;
        # NEW: secrets embedded as webhook/URL query-string parameters, e.g.
        # https://example.com/hook?token=abcd or ?api_key=... in hooks.json
        s#([?&](?:token|key|secret|password|api_key|access_token)=)[^&\s"\x27]+#$1\[REDACTED]#gi;
      ' "$f"
      n=$((n + 1))
    fi
  done < <(find "$BACKUP_DIR" \( -path '*/source' -o -path '*/wiki-source' -o -name objects -o -name '*.pack' \) -prune -o \
             -type f \( -name config -o -name FETCH_HEAD -o -name '*.json' \) -print0)
  # personal data: e-mail addresses in API metadata only (not in git history/source)
  # Only descend into the metadata dirs when they exist: `find` on a missing
  # path exits non-zero, which trips the ERR trap and prints a scary warning
  # for a completely normal situation (no gh / no metadata collected).
  for md in "$BACKUP_DIR/org-meta" "$BACKUP_DIR/repo-meta"; do
    [ -d "$md" ] || continue
    while IFS= read -r -d '' f; do
      perl -0pi -e 's#(?<![\w.+-])[\w.+-]+@(?!users\.noreply\.github\.com)[\w-]+(?:\.[\w-]+)+#[REDACTED:email]#g' "$f"
    done < <(find "$md" -type f -name '*.json' -print0)
  done
  log "Sanitized $n config/metadata file(s)"
  # fail closed: no token may remain in the files we just cleaned
  if find "$BACKUP_DIR" \( -path '*/source' -o -path '*/wiki-source' -o -name objects -o -name '*.pack' \) -prune -o \
       -type f \( -name config -o -name FETCH_HEAD -o -name '*.json' \) -print0 \
       | xargs -0 -r grep -aElq "$TOKEN_RE"; then
    die "a token pattern is still present in config/metadata files after sanitizing; aborting before archive"
  fi
}
if [ "$DRY_RUN" != 1 ]; then sanitize_dir; else log "[dry-run] sanitize_dir"; fi

# ---------------------------------------------- manifest (machine readable)
if [ "$DRY_RUN" != 1 ]; then
  MANIFEST="$BACKUP_DIR/backup-manifest.json"
  {
    printf '{\n  "org": "%s",\n  "timestamp": "%s",\n  "hostname": "%s",\n' \
      "$ORG" "$(date -u +%FT%TZ)" "$(hostname 2>/dev/null || echo unknown)"
    printf '  "repositories": ['
    first=1
    # FIX: a plain */ glob skips dot-directories, so the `.github` repository
    # was in the backup but missing from the manifest.
    shopt -s dotglob nullglob
    for d in "$BACKUP_DIR"/repositories/*/; do
      [ -d "$d" ] || continue
      name="$(basename "${d%/}")"
      head_sha="$(git --git-dir="${d%/}/repository" rev-parse HEAD 2>/dev/null || echo null)"
      [ "$first" = 1 ] || printf ','
      printf '\n    {"name": "%s", "head": %s}' "$name" \
        "$([ "$head_sha" = null ] && echo null || echo "\"$head_sha\"")"
      first=0
    done
    shopt -u dotglob nullglob
    printf '\n  ],\n  "encrypted": %s,\n  "include_source": %s\n}\n' \
      "$([ "$ENCRYPT" = 7z ] || [ "$ENCRYPT" = gpg ] && echo true || echo false)" \
      "$([ "$INCLUDE_SOURCE" = 1 ] && echo true || echo false)"
  } > "$MANIFEST"
  log "Wrote $MANIFEST"
fi

# -------------------------------------------------------------- archive
PARENT="$(dirname "$BACKUP_DIR")"
BASE="$(basename "$BACKUP_DIR")"
if [ "$ENCRYPT" = 7z ]; then
  if ! command -v 7z >/dev/null 2>&1; then
    # FIX: `sudo apt-get` was unconditional. It fails without sudo, on non-Debian
    # distros and on macOS. Try, then tell the user exactly what to install.
    log "installing p7zip"
    if command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
      if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update -qq && sudo apt-get install -y -qq p7zip-full
      elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y -q p7zip p7zip-plugins
      elif command -v brew >/dev/null 2>&1; then
        sudo brew install p7zip
      fi
    fi
    command -v 7z >/dev/null 2>&1 \
      || die "7z is required for ENCRYPT=7z. Install it (apt: p7zip-full, dnf: p7zip-plugins, brew: p7zip) or use ENCRYPT=none."
  fi
  ARCHIVE="$OUT_DIR/$ORG-$DATE.7z"
  rm -f "$ARCHIVE"
  # NEW: ARCHIVE_PASSWORD lets this run unattended (CI, a cron job with no
  # tty) instead of only ever prompting interactively.
  if [ -n "${ARCHIVE_PASSWORD:-}" ]; then
    PW1="$ARCHIVE_PASSWORD"
  else
    log "Set an archive password (ASCII characters only)."
    if [ ! -t 0 ]; then die "ENCRYPT=7z needs ARCHIVE_PASSWORD set, or an interactive password prompt"; fi
    while :; do
      read -rsp "Archive password: " PW1; echo
      read -rsp "Password (again): " PW2; echo
      if [ -n "$PW1" ] && [ "$PW1" = "$PW2" ]; then break; fi
      log "Passwords are empty or do not match, try again."
    done
  fi
  if [ "$DRY_RUN" = 1 ]; then
    log "[dry-run] 7z a -t7z -mhe=on -p*** $ARCHIVE $BASE"
  else
    (cd "$PARENT" && 7z a -t7z -mhe=on -p"$PW1" -bd "$ARCHIVE" "$BASE" >/dev/null) \
      || die "could not create archive"
    log "Testing archive"
    7z t -p"$PW1" -bd "$ARCHIVE" >/dev/null || die "archive test failed"
    log "Archive test passed"
  fi
  unset PW1 PW2
elif [ "$ENCRYPT" = gpg ]; then
  # NEW: GPG symmetric encryption as a lighter alternative to 7z - no extra
  # package on most systems (gpg ships with git/ssh toolchains already).
  command -v gpg >/dev/null 2>&1 \
    || die "gpg is required for ENCRYPT=gpg. Install it (apt/dnf: gnupg, brew: gnupg) or use ENCRYPT=none/7z."
  ARCHIVE="$OUT_DIR/$ORG-$DATE.tar.gz.gpg"
  rm -f "$ARCHIVE"
  if [ "$DRY_RUN" = 1 ]; then
    log "[dry-run] tar -czf - $BASE | gpg --symmetric -o $ARCHIVE"
    if [ -n "${ARCHIVE_PASSWORD:-}" ]; then
      log "ARCHIVE_PASSWORD is set - would encrypt non-interactively."
    else
      log "WARNING: ENCRYPT=gpg will prompt interactively for a passphrase (twice, via gpg's own prompt)."
    fi
  else
    # NEW: ARCHIVE_PASSWORD lets this run unattended (CI, a cron job with no
    # tty) instead of only ever using gpg's interactive pinentry prompt.
    if [ -z "${ARCHIVE_PASSWORD:-}" ] && [ ! -t 0 ]; then
      die "ENCRYPT=gpg needs ARCHIVE_PASSWORD set, or an interactive passphrase prompt"
    fi
    TMPTAR="$(mktemp)"
    tar -czf "$TMPTAR" -C "$PARENT" "$BASE" || die "could not create archive"
    if [ -n "${ARCHIVE_PASSWORD:-}" ]; then
      # Passphrase goes in on fd 0, never argv/ps, same as the interactive path.
      gpg --batch --yes --passphrase-fd 0 --symmetric --cipher-algo AES256 \
        -o "$ARCHIVE" "$TMPTAR" <<<"$ARCHIVE_PASSWORD" \
        || { rm -f "$TMPTAR"; die "gpg encryption failed"; }
    else
      # gpg's own pinentry/tty prompt asks for and confirms the passphrase;
      # nothing sensitive goes on the command line or into argv.
      gpg --symmetric --cipher-algo AES256 -o "$ARCHIVE" "$TMPTAR" \
        || { rm -f "$TMPTAR"; die "gpg encryption failed"; }
    fi
    rm -f "$TMPTAR"
    log "Testing archive"
    if [ -n "${ARCHIVE_PASSWORD:-}" ]; then
      gpg --batch --yes --passphrase-fd 0 -d -o /dev/null "$ARCHIVE" \
        <<<"$ARCHIVE_PASSWORD" || die "archive test (decrypt) failed"
    else
      gpg --batch --yes -d -o /dev/null "$ARCHIVE" || die "archive test (decrypt) failed"
    fi
    log "Archive test passed"
  fi
else
  ARCHIVE="$OUT_DIR/$ORG-$DATE.tar.gz"
  if [ "$DRY_RUN" = 1 ]; then
    log "[dry-run] tar -czf $ARCHIVE -C $PARENT $BASE"
    log "WARNING: the archive would NOT be encrypted."
  else
    note "the archive is NOT encrypted (you asked for --encrypt none). It contains private code; encrypt it before uploading anywhere."
    tar -czf "$ARCHIVE" -C "$PARENT" "$BASE"
    tar -tzf "$ARCHIVE" >/dev/null || die "archive verification failed"
    # FIX: `tar -tzf` only proves the archive is readable, not that it contains
    # the repositories. Count them and compare against what was backed up.
    # Same missing-directory guard as ACTUAL above: `find` on an absent path
    # exits 1 and pipefail turns that into an abort.
    want=0
    if [ -d "$BACKUP_DIR/repositories" ]; then
      want="$(find "$BACKUP_DIR/repositories" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
    fi
    got="$(tar -tzf "$ARCHIVE" | grep -c "/repositories/[^/]*/repository/HEAD$" || true)"
    if [ "${want:-0}" -gt 0 ] && [ "${got:-0}" != "${want:-0}" ]; then
      die "archive contains $got bare repositories but $want were backed up - refusing to prune or finish"
    fi
    log "Archive content verified: $got bare repository(ies) present"
  fi
fi

if [ "$DRY_RUN" != 1 ]; then
  hash_archive "$ARCHIVE" || true
fi

# ------------------------------------------- NEW: secondary copy via rsync
# Local disk, mounted NAS, or an SSH host - no cloud API/account involved.
if [ -n "$COPY_TO" ]; then
  if ! command -v rsync >/dev/null 2>&1; then
    warn "COPY_TO is set but rsync is not installed; skipping secondary copy"
  elif [ "$DRY_RUN" = 1 ]; then
    log "[dry-run] rsync -a $ARCHIVE ${ARCHIVE}.sha256 $COPY_TO/"
  else
    if rsync -a "$ARCHIVE" "$ARCHIVE.sha256" "$COPY_TO/" 2>/dev/null; then
      log "Copied archive to $COPY_TO"
    else
      warn "rsync to $COPY_TO failed; the primary archive in $OUT_DIR is still intact"
    fi
  fi
fi

# ------------------------------------------------- prune old archives
# FIX: the old pipeline used `find -printf '%T@ %p\n' | cut -d' ' -f2-`, which
# is GNU-only and breaks on filenames containing spaces. Sort by mtime
# portably and keep names intact.
if [ "$DRY_RUN" != 1 ]; then
  pruned=0
  tmplist="$(mktemp)"
  for f in "$OUT_DIR/$ORG"-*.7z "$OUT_DIR/$ORG"-*.tar.gz "$OUT_DIR/$ORG"-*.tar.gz.gpg; do
    [ -f "$f" ] || continue
    printf '%s %s\n' "$(mtime_of "$f")" "$f" >> "$tmplist"
  done
  # newest first; skip the newest $KEEP
  total=$(wc -l < "$tmplist" | tr -d ' ')
  if [ "$total" -gt "$KEEP" ]; then
    sort -rn "$tmplist" | tail -n +$((KEEP + 1)) | cut -d' ' -f2- |
      while IFS= read -r old; do
        [ -n "$old" ] || continue
        log "removing old archive: $old"
        rm -f -- "$old" "$old.sha256"
      done
    pruned=$((total - KEEP))
  fi
  rm -f "$tmplist"
  log "Pruning: kept the newest $KEEP of $total archive(s), removed $pruned"
fi

# -------------------------------------------------------------- summary
echo
log "Done."
if [ "$DRY_RUN" = 1 ]; then
  echo "  (dry run - nothing was written)"
else
  echo "  Archive: $ARCHIVE ($(du -h "$ARCHIVE" | cut -f1))"
  [ -f "$ARCHIVE.sha256" ] && echo "  SHA256 : $(cut -d' ' -f1 "$ARCHIVE.sha256")"
  echo "  Log    : $LOG_FILE"
fi
echo
echo "Next steps:"
echo "  1. Download the archive and verify it locally:"
echo "       bash $0 --verify-only /path/to/$(basename "${ARCHIVE:-archive}")"
echo "  2. Try restoring one repository from the bare clone:"
echo "       git clone <archive>/repositories/<name>/repository restored-<name>"
echo "  3. Revoke the token on GitHub (Settings > Developer settings)"
echo "  4. Only then delete the machine this ran on"
if [ "$DRY_RUN" != 1 ]; then
  echo "  Note: the unencrypted backup folder is still here: $BACKUP_DIR"
fi

# Report the warning count unconditionally: on a backup tool "it exited 0" has
# to be distinguishable from "it exited 0 but eleven endpoints 403'd".
echo
if [ "$WARN_COUNT" -gt 0 ]; then
  echo "  Warnings during this run: $WARN_COUNT (re-run with --strict to fail on any)"
else
  echo "  Warnings during this run: 0"
fi

# --strict turns any warning into a failure. Without it the script exited 0
# even when half the org was skipped for lack of a permission, so CI reported a
# partial backup as a success. Placed after the summary so the archive path is
# already on screen when the run is declared incomplete.
if [ "$STRICT" = 1 ] && [ "$WARN_COUNT" -gt 0 ]; then
  die "$WARN_COUNT warning(s) during this run and --strict was given; treating the backup as incomplete"
fi

# `tee` is a coprocess attached to our stdout. Closing our end and reaping it is
# the only way to be sure the summary above actually reached $LOG_FILE - without
# this the last lines can still be in tee's buffer when the script exits, so the
# log silently ends before "Done." and a reader debugging a failed run loses
# exactly the part they need.
exec >&- 2>&-
wait || true
