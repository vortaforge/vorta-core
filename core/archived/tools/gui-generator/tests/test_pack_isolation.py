"""Two generated packs loaded together must not share any global state.

AI-assisted: written with Claude (Anthropic) — see CREDITS.md.
"""

from __future__ import annotations

import re

from guigenmc.generators import generate_datapack
from guigenmc.models import menu_from_dict

LEGACY = re.compile(
    r"guigen_(menu_timer|page|click|tmp|rand|opened)\b|guigen\.(open|last|close)\b"
)


def _menu(ns: str) -> dict:
    return menu_from_dict(
        {
            "namespace": ns,
            "menu_id": "main",
            "pages": [
                {
                    "index": 0,
                    "name": "Main",
                    "widgets": [
                        # identical action ids in both packs on purpose
                        {
                            "kind": "button",
                            "slot": 13,
                            "item": "minecraft:diamond",
                            "name": {"text": "Go"},
                            "commands": ["say hi"],
                            "cooldown_ticks": 20,
                            "action_id": "go",
                        },
                        {"kind": "close", "slot": 26},
                    ],
                }
            ],
        }
    )


def _text(files: dict[str, str]) -> str:
    return "\n".join(v for k, v in files.items() if k.endswith(".mcfunction"))


def _objectives(files: dict[str, str]) -> set[str]:
    load = files[next(k for k in files if k.endswith("core/load.mcfunction"))]
    return set(re.findall(r"scoreboard objectives add (\S+)", load))


def test_no_legacy_global_names_left() -> None:
    assert not LEGACY.search(_text(generate_datapack(_menu("aaa"))))


def test_objectives_and_triggers_are_disjoint_between_packs() -> None:
    a = _objectives(generate_datapack(_menu("aaa")))
    b = _objectives(generate_datapack(_menu("bbb")))
    assert a and b
    assert a.isdisjoint(b), a & b


def test_every_scoreboard_reference_is_namespaced() -> None:
    files = generate_datapack(_menu("aaa"))
    for name in re.findall(r"scores=\{(guigen[^=]+)=", _text(files)):
        assert name.startswith("guigen.aaa."), name


def test_widget_custom_data_is_pack_scoped() -> None:
    a = generate_datapack(_menu("aaa"))
    b = generate_datapack(_menu("bbb"))
    # detection/clear lines of pack A must never match pack B's items
    for line in _text(a).splitlines():
        if "custom_data" in line:
            assert 'pack:"aaa"' in line, line
    assert 'pack:"aaa"' not in _text(b)


def test_trigger_dispatch_targets_only_own_pack() -> None:
    tick = generate_datapack(_menu("aaa"))["data/aaa/function/core/tick.mcfunction"]
    assert "guigen.aaa.open=1.." in tick
    assert "guigen.bbb" not in tick
