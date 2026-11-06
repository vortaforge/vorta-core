#!/usr/bin/env python3
"""Receive a repository event and append it to the ledger immediately.

The scheduled sync is the safety net; this is the fast path. GitHub can call this
endpoint the moment something happens in the organization, so a creation or a
deletion is recorded within seconds instead of waiting for the next sweep.

Two modes, because the honest answer is that only one of them can be trusted in
a public repository:

  * **webhook mode** (`--secret` set) - the request's `X-Hub-Signature-256` is
    verified against the shared secret with an HMAC. This is the real deployment:
    point an organization webhook at a small always-on service running this
    script, and a forged POST cannot inject ledger entries.

  * **dispatch mode** (`--from-dispatch`) - the payload came from
    `repository_dispatch`, which is authenticated by the API token that sent it.
    No HMAC is involved because there is no webhook hop.

Both feed the same `record_event.append`, so there is exactly one writer and one
format regardless of which door the event came in through.

Deliberately NOT done here: talking to GitHub. Recording must not depend on a
second network call succeeding - if GitHub is briefly unreachable, the event is
still in the ledger and the scheduled reconciliation sorts the index out later.

Usage (webhook service):
    python3 scripts/receive_event.py --secret "$WEBHOOK_SECRET" --port 8080

Usage (Actions job, from a repository_dispatch payload file):
    python3 scripts/receive_event.py --from-dispatch payload.json
"""
from __future__ import annotations

import argparse
import hashlib
import hmac
import json
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from record_event import append  # noqa: E402

LEDGER = Path("events.log")

# Only these `action` values map to a ledger entry. GitHub sends far more
# repository events (`edited`, `transferred`, ...) and recording all of them would
# turn the ledger into a webhook dump.
REPOSITORY_ACTIONS = {
    "created": "created",
    "deleted": "deleted",
    "archived": "archived",
    "unarchived": "unarchived",
    "renamed": "renamed",
    "transferred": None,   # recorded as `renamed` by the caller, not here
}


def verify_signature(secret: str, body: bytes, header: str | None) -> bool:
    """Constant-time HMAC check.

    `hmac.compare_digest` rather than `==` so a wrong signature cannot be walked
    byte by byte by timing the response.
    """
    if not header or not header.startswith("sha256="):
        return False
    expected = hmac.new(secret.encode(), body, hashlib.sha256).hexdigest()
    return hmac.compare_digest(f"sha256={expected}", header)


def event_from_webhook(kind: str, payload: dict) -> dict | None:
    """Translate a GitHub webhook payload into one ledger event."""
    if kind == "repository":
        action = payload.get("action")
        if action not in REPOSITORY_ACTIONS or action == "transferred":
            return None
        repo = (payload.get("repository") or {}).get("name")
        if not repo:
            return None
        return {
            "type": REPOSITORY_ACTIONS[action],
            "repo": repo,
            "detail": (payload.get("repository") or {}).get("description") or "",
            "actor": (payload.get("sender") or {}).get("login") or "webhook",
        }

    if kind == "push":
        repo = (payload.get("repository") or {}).get("name")
        if not repo:
            return None
        commits = len(payload.get("commits") or [])
        ref = payload.get("ref", "").replace("refs/heads/", "")
        return {
            "type": "changed",
            "repo": repo,
            "detail": f"{commits} commit(s) to {ref}",
            "actor": (payload.get("sender") or {}).get("login") or "webhook",
        }

    return None


def event_from_dispatch(payload: dict) -> dict | None:
    """`repository_dispatch` carries a `client_payload` we control."""
    body = payload.get("client_payload") or {}
    repo = body.get("repo") or (payload.get("repository") or {}).get("name")
    kind = body.get("type")
    if not repo or kind not in ("created", "deleted", "changed", "archived",
                                "unarchived", "renamed", "visibility"):
        return None
    event = {"type": kind, "repo": repo, "actor": "repository_dispatch"}
    if body.get("detail"):
        event["detail"] = str(body["detail"])[:400]
    if body.get("at"):
        event["at"] = body["at"]
    return event


def make_handler(secret: str, ledger: Path):
    class Handler(BaseHTTPRequestHandler):
        server_version = "vorta-core/1"

        def do_POST(self) -> None:  # noqa: N802 - BaseHTTPRequestHandler's naming
            length = int(self.headers.get("Content-Length") or 0)
            body = self.rfile.read(length)
            signature = self.headers.get("X-Hub-Signature-256")

            if secret and not verify_signature(secret, body, signature):
                # 401, and no detail about *why*: telling a prober whether the
                # secret is wrong or the header is missing only helps them.
                self.send_response(401)
                self.end_headers()
                self.wfile.write(b'{"error":"bad signature"}')
                return

            try:
                payload = json.loads(body or b"{}")
            except json.JSONDecodeError:
                self.send_response(400)
                self.end_headers()
                self.wfile.write(b'{"error":"bad json"}')
                return

            event = event_from_webhook(self.headers.get("X-GitHub-Event", ""), payload)
            if event is None:
                # 204: accepted and deliberately ignored. Returning an error would
                # make GitHub mark the delivery red for a `repository.edited`,
                # which is not a failure.
                self.send_response(204)
                self.end_headers()
                return

            append(ledger, event)
            self.send_response(202)
            self.end_headers()
            self.wfile.write(json.dumps(event).encode())

        def do_GET(self) -> None:  # noqa: N802
            # A plain liveness probe. The ledger itself is never served: it is
            # repository metadata and belongs in the repository, not on an
            # unauthenticated HTTP port.
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(b'{"status":"ok"}')

        def log_message(self, fmt: str, *args) -> None:
            sys.stderr.write("%s - %s\n" % (self.address_string(), fmt % args))

    return Handler


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--secret", default="",
                        help="webhook secret; omit to run unverified (testing only)")
    parser.add_argument("--port", type=int, default=8080)
    parser.add_argument("--ledger", type=Path, default=LEDGER)
    parser.add_argument("--from-dispatch", type=Path, default=None,
                        help="read one repository_dispatch payload and exit")
    args = parser.parse_args(argv)

    if args.from_dispatch:
        payload = json.loads(args.from_dispatch.read_text(encoding="utf-8"))
        event = event_from_dispatch(payload)
        if event is None:
            print("no usable event in payload", file=sys.stderr)
            return 1
        append(args.ledger, event)
        print(json.dumps(event, sort_keys=True))
        return 0

    if not args.secret:
        sys.stderr.write(
            "warning: no --secret, signatures are NOT verified. Fine for a local\n"
            "         test; a public endpoint must pass --secret.\n")

    server = HTTPServer(("0.0.0.0", args.port), make_handler(args.secret, args.ledger))
    sys.stderr.write(f"listening on 0.0.0.0:{args.port} -> {args.ledger}\n")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
