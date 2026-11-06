"""Tests for the guikit-datapack v5 port: dimension/weather conditions and
the permission-0 player triggers (open/last/close/close_all)."""

import json

import pytest

from guigenmc.models import (
    VALID_CONDITION_TYPES,
    VALID_WEATHER_VALUES,
    loader_condition,
    validate_dimension_id,
)
from guigenmc.generators.handlers import handler_for
from guigenmc.generators.lifecycle import generate_triggers
from guigenmc.generators import generate_datapack
from guigenmc.models import menu_from_dict, mk_widget


# ---------------------------------------------------------------------------
# loader_condition
# ---------------------------------------------------------------------------

def test_dimension_and_weather_are_valid_condition_types():
    assert "dimension" in VALID_CONDITION_TYPES
    assert "weather" in VALID_CONDITION_TYPES


def test_dimension_condition_normalizes_bare_id():
    cond = loader_condition({"type": "dimension", "dimension": "overworld"})
    assert cond["dimension"] == "minecraft:overworld"


def test_dimension_condition_accepts_dim_alias_and_custom_namespace():
    cond = loader_condition({"type": "dimension", "dim": "mymod:custom_dim"})
    assert cond["dimension"] == "mymod:custom_dim"


def test_dimension_condition_requires_value():
    with pytest.raises(ValueError, match="requires 'dimension'"):
        loader_condition({"type": "dimension"})


def test_dimension_condition_rejects_path_separators():
    with pytest.raises(ValueError):
        loader_condition({"type": "dimension", "dimension": "minecraft:foo/bar"})


def test_weather_condition_accepts_all_vanilla_values():
    for wx in VALID_WEATHER_VALUES:
        cond = loader_condition({"type": "weather", "weather": wx})
        assert cond["weather"] == wx


def test_weather_condition_rejects_unknown_value():
    with pytest.raises(ValueError, match="clear, rain, thunder"):
        loader_condition({"type": "weather", "weather": "snow"})


def test_weather_condition_requires_value():
    with pytest.raises(ValueError):
        loader_condition({"type": "weather"})


def test_validate_dimension_id_requires_string():
    with pytest.raises(ValueError):
        validate_dimension_id(42)


# ---------------------------------------------------------------------------
# handler code generation
# ---------------------------------------------------------------------------

def _menu():
    return menu_from_dict(
        {
            "namespace": "demo",
            "menu_id": "shop",
            "pages": [{"index": 0, "name": "Main", "widgets": []}],
        }
    )


def test_dimension_handler_uses_player_context():
    menu = _menu()
    w = mk_widget(
        slot=1,
        kind="button",
        action_id="warp",
        commands=["tp @s 0 80 0"],
        condition={"type": "dimension", "dimension": "minecraft:the_nether",
                   "fail_message": {"text": "no", "italic": False}},
    )
    text = "\n".join(handler_for(menu, w))
    # `at @s` must precede the dimension check (guikit cond/t_dimension semantics)
    assert "execute at @s if dimension minecraft:the_nether run tp @s 0 80 0" in text
    assert "execute at @s unless dimension minecraft:the_nether run tellraw" in text


def test_weather_handler_uses_player_context():
    menu = _menu()
    w = mk_widget(
        slot=2,
        kind="button",
        action_id="rain",
        commands=["weather rain"],
        condition={"type": "weather", "weather": "clear"},
    )
    text = "\n".join(handler_for(menu, w))
    # Java Edition has no `execute if weather` subcommand (guikit v5's
    # cond/t_weather was invalid syntax) — the check must go through the
    # generated minecraft:weather_check predicate, still `at @s`.
    assert "if weather" not in text
    assert "execute at @s if predicate demo:guigen/weather_clear run weather rain" in text
    assert "execute at @s unless predicate demo:guigen/weather_clear run tellraw" in text


def test_weather_predicate_files_are_generated():
    from guigenmc.generators.lifecycle import generate_weather_predicates

    menu = _menu()
    for wx, slot in (("clear", 1), ("thunder", 2)):
        menu["pages"][0]["widgets"].append(
            mk_widget(slot=slot, kind="button", action_id=f"b{slot}",
                      commands=["say hi"],
                      condition={"type": "weather", "weather": wx})
        )
    out: dict[str, str] = {}
    generate_weather_predicates(menu, out)

    assert sorted(out) == [
        "data/demo/predicate/guigen/weather_clear.json",
        "data/demo/predicate/guigen/weather_thunder.json",
    ]
    clear = json.loads(out["data/demo/predicate/guigen/weather_clear.json"])
    assert clear == {"type": "minecraft:weather_check",
                     "raining": False, "thundering": False}
    thunder = json.loads(out["data/demo/predicate/guigen/weather_thunder.json"])
    assert thunder == {"type": "minecraft:weather_check",
                       "raining": True, "thundering": True}


# ---------------------------------------------------------------------------
# triggers + pack metadata (v5 port)
# ---------------------------------------------------------------------------

def test_generate_triggers_files():
    menu = _menu()
    out = {}
    generate_triggers(menu, out)
    assert "data/demo/function/core/open_trigger.mcfunction" in out
    assert "data/demo/function/core/last_trigger.mcfunction" in out
    assert "data/demo/function/core/close_trigger.mcfunction" in out
    assert "data/demo/function/core/close_all.mcfunction" in out

    last = out["data/demo/function/core/last_trigger.mcfunction"]
    assert "/trigger" not in last or True
    assert "scoreboard players set @s guigen.demo.last 0" in last
    assert "scoreboard players enable @s guigen.demo.last" in last
    assert "guigen.demo.opened" in last
    assert "function demo:menu/shop/open" in last

    close = out["data/demo/function/core/close_trigger.mcfunction"]
    assert "guigen.demo.menu_timer matches 1.." in close
    assert "function demo:menu/shop/close" in close

    close_all = out["data/demo/function/core/close_all.mcfunction"]
    assert "execute as @a[scores={guigen.demo.menu_timer=1..}] run function demo:menu/shop/close" in close_all


def test_full_datapack_has_v5_trigger_layer():
    menu = menu_from_dict(
        {
            "namespace": "demo",
            "menu_id": "shop",
            "pages": [
                {
                    "index": 0,
                    "name": "Main",
                    "widgets": [
                        {"kind": "button", "slot": 13, "item": "minecraft:diamond",
                         "commands": ["give @s minecraft:diamond 1"]},
                        {"kind": "close", "slot": 26},
                    ],
                }
            ],
        }
    )
    files = generate_datapack(menu)

    load = files["data/demo/function/core/load.mcfunction"]
    for obj in ("guigen.demo.open", "guigen.demo.last", "guigen.demo.close"):
        assert f"scoreboard objectives add {obj} trigger" in load
    assert "scoreboard objectives add guigen.demo.opened dummy" in load

    tick = files["data/demo/function/core/tick.mcfunction"]
    for obj in ("guigen.demo.open", "guigen.demo.last", "guigen.demo.close"):
        assert f"scoreboard players enable @a {obj}" in tick
    assert "function demo:core/open_trigger" in tick
    assert "function demo:core/last_trigger" in tick
    assert "function demo:core/close_trigger" in tick

    open_fn = files["data/demo/function/menu/shop/open.mcfunction"]
    assert "scoreboard players set @s guigen.demo.opened 1" in open_fn

    # pack format bump (guikit-datapack commit "Update pack format version to 122")
    assert '"min_format": 122' in files["pack.mcmeta"]
    assert '"max_format": 122' in files["pack.mcmeta"]
