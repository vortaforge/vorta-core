"""Tests for the radio button and page tab widgets."""

import pytest

from guigenmc.models import (
    VALID_WIDGET_KINDS,
    collect_scores,
    loader_widget,
    menu_from_dict,
    mk_widget,
)
from guigenmc.generators import generate_datapack
from guigenmc.generators.fill import emit_radio, emit_tab
from guigenmc.generators.handlers import handler_for
from guigenmc.validate import validate_menu


def _radio(**over):
    raw = {
        "kind": "radio",
        "slot": 11,
        "radio": {
            "score": "srv_mode",
            "value": 0,
            "off_item": "minecraft:gray_dye",
            "on_item": "minecraft:lime_dye",
            "off_name": {"text": "Mode: Off"},
            "on_name": {"text": "Mode: A"},
        },
    }
    raw.update(over)
    return raw


def _tab(**over):
    raw = {
        "kind": "tab",
        "slot": 22,
        "target_page": 1,
        "tab": {
            "off_item": "minecraft:gray_stained_glass_pane",
            "on_item": "minecraft:lime_stained_glass_pane",
        },
        "name": {"text": "Shop"},
    }
    raw.update(over)
    return raw


def _menu(widgets):
    return menu_from_dict(
        {
            "namespace": "demo",
            "menu_id": "m",
            "pages": [
                {"index": 0, "name": "Main", "widgets": widgets},
                {"index": 1, "name": "Other", "widgets": [{"kind": "close", "slot": 26}]},
            ],
        }
    )


# ---------------------------------------------------------------------------
# loader
# ---------------------------------------------------------------------------

def test_radio_and_tab_are_valid_kinds():
    assert "radio" in VALID_WIDGET_KINDS
    assert "tab" in VALID_WIDGET_KINDS


def test_radio_loader_valid():
    w = loader_widget(_radio())
    assert w["radio"]["score"] == "srv_mode"
    assert w["radio"]["value"] == 0
    assert w["action_id"] == "srv_mode_v0"
    assert w["item"] == "minecraft:gray_dye"


def test_radio_loader_rejects_missing_fields():
    raw = _radio()
    del raw["radio"]["on_item"]
    with pytest.raises(ValueError, match="on_item"):
        loader_widget(raw)


def test_radio_loader_rejects_non_integer_value():
    raw = _radio()
    raw["radio"]["value"] = "abc"
    with pytest.raises(ValueError, match="integer"):
        loader_widget(raw)


def test_radio_loader_flat_form():
    w = loader_widget(
        {
            "kind": "radio",
            "slot": 12,
            "score": "srv_mode",
            "value": 2,
            "off_item": "minecraft:gray_dye",
            "on_item": "minecraft:lime_dye",
            "off_name": {"text": "off"},
            "on_name": {"text": "on"},
        }
    )
    assert w["radio"]["value"] == 2


def test_radio_loader_requires_object():
    with pytest.raises(ValueError, match="radio"):
        loader_widget({"kind": "radio", "slot": 1})


def test_tab_loader_valid():
    w = loader_widget(_tab())
    assert w["tab"]["off_item"] == "minecraft:gray_stained_glass_pane"
    assert w["target_page"] == 1
    assert w["action_id"] == "tab_22"


def test_tab_loader_requires_tab_object():
    raw = _tab()
    del raw["tab"]
    with pytest.raises(ValueError, match="tab"):
        loader_widget(raw)


def test_tab_loader_requires_target_page():
    raw = _tab()
    del raw["target_page"]
    with pytest.raises(ValueError, match="target_page"):
        loader_widget(raw)


def test_collect_scores_includes_radio_score():
    menu = _menu([_radio()])
    assert "srv_mode" in collect_scores(menu)


# ---------------------------------------------------------------------------
# rendering (page fill)
# ---------------------------------------------------------------------------

def test_emit_radio_renders_selected_and_unselected():
    menu = _menu([_radio()])
    w = menu["pages"][0]["widgets"][0]
    lines = emit_radio(menu, w)
    assert any(
        l.startswith("execute unless score @s srv_mode matches 0 run item replace")
        for l in lines
    )
    assert any(
        l.startswith("execute if score @s srv_mode matches 0 run item replace")
        for l in lines
    )
    # selected state uses the on_item
    assert any("lime_dye" in l for l in lines)
    assert any("gray_dye" in l for l in lines)


def test_emit_tab_highlights_active_page():
    menu = _menu([_tab()])
    w = menu["pages"][0]["widgets"][0]
    lines = emit_tab(menu, w)
    assert any(
        l.startswith("execute unless score @s guigen.demo.page matches 1 run item replace")
        for l in lines
    )
    assert any(
        l.startswith("execute if score @s guigen.demo.page matches 1 run item replace")
        for l in lines
    )


# ---------------------------------------------------------------------------
# click handlers
# ---------------------------------------------------------------------------

def test_radio_handler_sets_group_score():
    menu = _menu([_radio()])
    w = menu["pages"][0]["widgets"][0]
    w["radio"]["on_commands"] = ["say picked A"]
    text = "\n".join(handler_for(menu, w))
    assert "scoreboard players set @s srv_mode 0" in text
    assert "say picked A" in text
    assert "tellraw @s" in text
    assert "function demo:menu/m/fill" in text


def test_tab_handler_navigates():
    menu = _menu([_tab()])
    w = menu["pages"][0]["widgets"][0]
    text = "\n".join(handler_for(menu, w))
    assert "scoreboard players set @s guigen.demo.page 1" in text
    assert "function demo:menu/m/fill" in text


# ---------------------------------------------------------------------------
# validation warnings
# ---------------------------------------------------------------------------

def test_validate_warns_on_duplicate_radio_values():
    menu = _menu([_radio(), _radio(slot=12)])
    warnings = validate_menu(menu)
    assert any("duplicate value" in msg for msg in warnings)


def test_validate_warns_on_solo_radio():
    menu = _menu([_radio()])
    warnings = validate_menu(menu)
    assert any("fewer than 2 distinct values" in msg for msg in warnings)


def test_validate_warns_on_tab_missing_page():
    menu = _menu([_tab(target_page=99)])
    warnings = validate_menu(menu)
    assert any("(tab) targets page 99" in msg for msg in warnings)


# ---------------------------------------------------------------------------
# full datapack integration
# ---------------------------------------------------------------------------

def test_full_datapack_with_radio_group_and_tabs():
    menu = menu_from_dict(
        {
            "namespace": "demo",
            "menu_id": "m",
            "pages": [
                {
                    "index": 0,
                    "name": "Main",
                    "widgets": [
                        _radio(),
                        _radio(slot=12, radio={
                            "score": "srv_mode",
                            "value": 1,
                            "off_item": "minecraft:gray_dye",
                            "on_item": "minecraft:lime_dye",
                            "off_name": {"text": "Mode: Off"},
                            "on_name": {"text": "Mode: B"},
                        }),
                        _tab(),
                        {"kind": "close", "slot": 26, "action_id": "close_main"},
                    ],
                },
                {"index": 1, "name": "Other", "widgets": [{"kind": "close", "slot": 26, "action_id": "close_other"}]},
            ],
        }
    )
    files = generate_datapack(menu)

    assert "scoreboard objectives add srv_mode dummy" in files["data/demo/function/core/load.mcfunction"]

    page0 = files["data/demo/function/menu/m/page/0.mcfunction"]
    assert "execute if score @s srv_mode matches 0 run item replace" in page0
    assert "execute if score @s srv_mode matches 1 run item replace" in page0
    assert "execute if score @s guigen.demo.page matches 1 run item replace" in page0

    open_fn = files["data/demo/function/menu/m/open.mcfunction"]
    assert "execute unless score @s srv_mode matches 0.. run scoreboard players set @s srv_mode 0" in open_fn

    assert files["data/demo/function/menu/m/click/srv_mode_v0.mcfunction"]
    assert files["data/demo/function/menu/m/click/srv_mode_v1.mcfunction"]
    assert files["data/demo/function/menu/m/click/tab_22.mcfunction"]
