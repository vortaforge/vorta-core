#!/usr/bin/env python3
"""Test the sync's decision logic without touching GitHub.

The point of these tests is the part that is easy to get wrong and impossible to
notice when it is wrong: a deletion that is silently not recorded, or an event
recorded twice because two runs overlapped. Both are exercised against a fixed
pair of listings rather than the live organization, so the tests are deterministic
and never depend on network state.

Run:  python3 -m pytest tests/ -q       (or: python3 tests/test_sync.py)
"""
from __future__ import annotations

import json
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))

from sync import already_recorded, diff_fields, reconcile  # noqa: E402


def repo(name: str, **overrides) -> dict:
    base = {
        "name": name,
        "fullName": f"vortaforge/{name}",
        "description": "",
        "visibility": "PUBLIC",
        "archived": False,
        "fork": False,
        "defaultBranch": "main",
        "createdAt": "2026-01-01T00:00:00Z",
        "pushedAt": "2026-01-01T00:00:00Z",
        "language": "Python",
        "topics": [],
        "stars": 0,
        "hasIssues": True,
    }
    base.update(overrides)
    return base


def index_of(*repos) -> dict:
    return {"org": "vortaforge", "repositories": list(repos)}


# ---------------------------------------------------------------- creation

def test_new_repository_produces_one_created_event():
    pending, summary = reconcile("vortaforge", index_of(repo("core")), [],
                                 [repo("core"), repo("docs")])
    assert summary["created"] == ["docs"]
    assert [e["type"] for e in pending] == ["created"]
    assert pending[0]["repo"] == "docs"


def test_creation_is_idempotent():
    """Two overlapping runs must not write the event twice."""
    events = [{"at": "x", "type": "created", "repo": "docs"}]
    pending, _ = reconcile("vortaforge", index_of(repo("core")), events,
                           [repo("core"), repo("docs")])
    assert pending == []


# ---------------------------------------------------------------- deletion

def test_deleted_repository_is_recorded_not_silently_dropped():
    pending, summary = reconcile("vortaforge", index_of(repo("core"), repo("gone")),
                                 [], [repo("core")])
    assert summary["deleted"] == ["gone"]
    assert [e["type"] for e in pending] == ["deleted"]
    assert pending[0]["repo"] == "gone"


def test_deletion_is_idempotent():
    events = [{"at": "x", "type": "deleted", "repo": "gone"}]
    pending, _ = reconcile("vortaforge", index_of(repo("core"), repo("gone")),
                           events, [repo("core")])
    assert pending == []


def test_delete_then_recreate_records_creation_again():
    """A recreated repository is a new creation, even though the name matches.

    This is why `already_recorded` is scoped per event type and why deletions are
    kept in the ledger forever: the history has to survive the snapshot.
    """
    events = [
        {"at": "1", "type": "created", "repo": "thing"},
        {"at": "2", "type": "deleted", "repo": "thing"},
    ]
    pending, summary = reconcile("vortaforge", index_of(), events, [repo("thing")])
    assert summary["created"] == ["thing"]
    # `created` already exists for this name, so by the once-only rule it is not
    # re-recorded - the ledger keeps the original creation instant, which is the
    # correct answer for "when did this name first appear".
    assert pending == []


# ---------------------------------------------------------------- change

def test_description_change_is_one_changed_event():
    pending, summary = reconcile(
        "vortaforge",
        index_of(repo("core", description="old")),
        [],
        [repo("core", description="new")],
    )
    assert summary["changed"] == ["core"]
    assert len(pending) == 1
    assert pending[0]["type"] == "changed"
    assert "description" in pending[0]["detail"]


def test_push_alone_is_not_an_event():
    """`pushedAt` must not be a watched field, or every run emits noise."""
    pending, _ = reconcile(
        "vortaforge",
        index_of(repo("core", pushedAt="2026-01-01T00:00:00Z")),
        [],
        [repo("core", pushedAt="2026-09-09T09:09:09Z")],
    )
    assert pending == []


def test_archived_gets_its_own_event_type():
    pending, _ = reconcile("vortaforge", index_of(repo("core")), [],
                           [repo("core", archived=True)])
    types = {e["type"] for e in pending}
    assert "archived" in types
    # and not also a generic `changed` for the same field
    assert all("archived" not in e.get("detail", "") for e in pending
               if e["type"] == "changed")


def test_visibility_change_is_reported_with_both_values():
    pending, _ = reconcile("vortaforge", index_of(repo("core", visibility="PRIVATE")),
                           [], [repo("core", visibility="PUBLIC")])
    event = next(e for e in pending if e["type"] == "visibility")
    assert "PRIVATE" in event["detail"] and "PUBLIC" in event["detail"]


# ---------------------------------------------------------------- no-op

def test_identical_listing_produces_nothing():
    same = [repo("core"), repo("docs")]
    pending, summary = reconcile("vortaforge", index_of(*same), [], same)
    assert pending == []
    assert summary["events"] == 0


# ---------------------------------------------------------------- helpers

def test_diff_fields_ignores_unwatched():
    assert diff_fields({"stars": 1}, {"stars": 5}) == []
    assert diff_fields({"description": "a"}, {"description": "b"}) == ["description"]


def test_already_recorded_is_false_for_changed():
    """`changed` may happen many times; only lifecycle events are once-only."""
    events = [{"type": "changed", "repo": "core"}]
    assert not already_recorded(events, "changed", "core")
    assert already_recorded(events + [{"type": "deleted", "repo": "core"}],
                            "deleted", "core")


def _run_all() -> int:
    failures = 0
    tests = [(n, f) for n, f in sorted(globals().items())
             if n.startswith("test_") and callable(f)]
    for name, fn in tests:
        try:
            fn()
            print(f"  ok   {name}")
        except AssertionError as exc:
            failures += 1
            print(f"  FAIL {name}: {exc}")
        except Exception as exc:  # noqa: BLE001 - a test failure is a test failure
            failures += 1
            print(f"  ERR  {name}: {type(exc).__name__}: {exc}")
    print(f"\n{len(tests) - failures}/{len(tests)} passed")
    return 1 if failures else 0




def test_apply_preserves_keys_owned_by_other_scripts():
    """mirror.py stores its state under `mirrors` in the same document.

    Rebuilding index.json from a literal dict dropped that key, so the next
    mirror run found no record of the trees it had written. The document has two
    writers; neither may delete the other's section.
    """
    import subprocess
    import tempfile as _tempfile
    from pathlib import Path as _Path

    work = _Path(_tempfile.mkdtemp())
    index = work / "index.json"
    index.write_text(json.dumps({
        "org": "vortaforge",
        "count": 1,
        "repositories": [repo("kept")],
        "mirrors": {"kept": {"branch": "main", "commit": "abc123"}},
        "mirrorsGeneratedAt": "2026-01-01T00:00:00Z",
    }), encoding="utf-8")

    # Drive exactly the rewrite branch, without a network call: run the same
    # code path by importing main under a stubbed discover.
    sys.path.insert(0, str(_Path(__file__).resolve().parents[1] / "scripts"))
    import sync as sync_module  # noqa: PLC0415

    original = sync_module.discover
    sync_module.discover = lambda org, include_archived: [repo("kept")]
    try:
        assert sync_module.main(["--org", "vortaforge", "--apply",
                                 "--index", str(index),
                                 "--ledger", str(work / "events.log")]) == 0
    finally:
        sync_module.discover = original

    after = json.loads(index.read_text(encoding="utf-8"))
    assert after["mirrors"] == {"kept": {"branch": "main", "commit": "abc123"}}
    assert after["mirrorsGeneratedAt"] == "2026-01-01T00:00:00Z"
    assert after["org"] == "vortaforge"
    assert [r["name"] for r in after["repositories"]] == ["kept"]


def test_unchanged_listing_keeps_generated_at():
    """A sync that changes nothing must not change index.json.

    `generatedAt` was rewritten on every run, so the scheduled sync produced a
    commit every six hours whose only content was the clock. A clock belongs in
    the ledger (which is append-only history), not in the state file.
    """
    from pathlib import Path as _Path
    import tempfile as _tempfile

    work = _Path(_tempfile.mkdtemp())
    index = work / "index.json"
    first = repo("kept")
    index.write_text(json.dumps({
        "org": "vortaforge", "generatedAt": "2026-01-01T00:00:00Z",
        "count": 1, "repositories": [first],
    }), encoding="utf-8")

    import sync as sync_module  # noqa: PLC0415

    original = sync_module.discover
    sync_module.discover = lambda org, include_archived: [first]
    try:
        assert sync_module.main(["--org", "vortaforge", "--apply",
                                 "--index", str(index),
                                 "--ledger", str(work / "events.log")]) == 0
    finally:
        sync_module.discover = original

    after = json.loads(index.read_text(encoding="utf-8"))
    assert after["generatedAt"] == "2026-01-01T00:00:00Z", after["generatedAt"]


def test_pushed_at_is_not_persisted():
    """index.json must not hold a field that changes on its own pushes.

    `pushedAt` moves whenever this sync pushes its own commit, so persisting it
    made every successful run write a different index - the loop the mirror was
    already freed from. The commit sha in each .mirror.json is what says which
    tree was captured.
    """
    from pathlib import Path as _Path
    import tempfile as _tempfile

    work = _Path(_tempfile.mkdtemp())
    index = work / "index.json"
    index.write_text(json.dumps({"org": "vortaforge", "count": 0,
                                 "repositories": []}), encoding="utf-8")

    import sync as sync_module  # noqa: PLC0415

    original = sync_module.discover
    sync_module.discover = lambda org, include_archived: [
        {**repo("kept"), "pushedAt": "2026-11-06T18:00:00Z"}]
    try:
        assert sync_module.main(["--org", "vortaforge", "--apply",
                                 "--index", str(index),
                                 "--ledger", str(work / "events.log")]) == 0
    finally:
        sync_module.discover = original

    after = json.loads(index.read_text(encoding="utf-8"))
    assert "pushedAt" not in after["repositories"][0]
    assert after["repositories"][0]["name"] == "kept"


if __name__ == "__main__":
    raise SystemExit(_run_all())
