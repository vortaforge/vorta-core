"""Load / open / close / tags / pack.mcmeta generators."""

from __future__ import annotations

import json
from typing import Any

from ..components import clear_all_widgets, item_air_command
from ..models import (
    all_widgets,
    collect_scores,
    container_entity_id,
    container_slot_count,
    container_summon_nbt,
    interactive_widgets,
    menu_core_prefix,
    menu_function_prefix,
    menu_tag,
    obj,
    resolved_action_id,
)
from ..paths import core_dir_path, menu_dir_path
from .handlers import cd_score


def generate_load(menu: dict[str, Any], out: dict[str, str]) -> None:
    lines = ["# Auto-generated core load"]
    scores = list(collect_scores(menu))
    for w in interactive_widgets(menu):
        if int(w.get("cooldown_ticks") or 0) > 0:
            sc = cd_score(resolved_action_id(w), menu)
            if sc not in scores:
                scores.append(sc)

    for score in scores:
        lines.append(f"scoreboard objectives add {score} dummy")
    # guikit-datapack v5 port: permission-0 player triggers
    lines.extend(
        [
            f"scoreboard objectives add {obj(menu, 'open')} trigger",
            f"scoreboard objectives add {obj(menu, 'last')} trigger",
            f"scoreboard objectives add {obj(menu, 'close')} trigger",
        ]
    )
    cart = f"@e[type={container_entity_id(menu['container'])},tag={menu_tag(menu)}]"
    lines.extend(
        [
            "",
            f"execute as {cart} run data modify entity @s Items set value []",
            f"kill {cart}",
            "",
            f'tellraw @a [{{"text":"[GUI-GENERATOR] ","color":"gray"}},'
            f'{{"text":"Loaded. /function {menu_function_prefix(menu)}/open","color":"green"}}]',
            "",
        ]
    )
    out[f"{core_dir_path(menu)}/load.mcfunction"] = "\n".join(lines)


def generate_open(menu: dict[str, Any], out: dict[str, str]) -> None:
    nbt = container_summon_nbt(
        menu["container"],
        [f"{menu['namespace']}.menu", menu_tag(menu)],
        menu["display_name"],
    )
    y_off = float(menu["container"].get("y_offset") or 0.0)
    if y_off:
        summon_coords = f"~ ~{y_off} ~"
    else:
        summon_coords = "~ ~ ~"
    lines = [
        "# Auto-generated open",
        f"function {menu_function_prefix(menu)}/close",
        "",
        f"summon {container_entity_id(menu['container'])} {summon_coords} {nbt}",
        "",
        f"scoreboard players set @s {obj(menu, 'page')} 0",
    ]
    for cmd in menu.get("on_open") or []:
        lines.append(str(cmd))
    if menu.get("on_open"):
        lines.append("")
    inited: set[str] = set()
    for w in all_widgets(menu):
        scores_to_init: list[str] = []
        if w.get("toggle"):
            scores_to_init.append(w["toggle"]["score"])
        if w.get("counter_score"):
            scores_to_init.append(w["counter_score"])
        if w.get("progress_score"):
            scores_to_init.append(w["progress_score"])
        if w.get("cycle"):
            scores_to_init.append(w["cycle"]["score"])
        if w.get("radio"):
            # default: the option with value 0 starts selected
            scores_to_init.append(w["radio"]["score"])
        for sc in scores_to_init:
            if sc in inited:
                continue
            inited.add(sc)
            lines.append(
                f"execute unless score @s {sc} matches 0.. run scoreboard players set @s {sc} 0"
            )
    lines.extend(
        [
            f"function {menu_function_prefix(menu)}/fill",
            f"scoreboard players set @s {obj(menu, 'menu_timer')} {menu['timer_ticks']}",
            "",
            "# guikit-datapack v5 port: world-saved memory of the last opened",
            "# menu — dummy scores persist across /reload, which powers",
            "# /trigger guigen.<ns>.last.",
            f"scoreboard players set @s {obj(menu, 'opened')} 1",
            "",
            'tellraw @s [{"text":"[GUI-GENERATOR] ","color":"gray"},'
            '{"text":"Menu opened. Right-click the cart, then SHIFT-click buttons.","color":"yellow"}]',
            'tellraw @s [{"text":"[GUI-GENERATOR] ","color":"gray"},'
            '{"text":"Tip: /trigger ' + obj(menu, "close") + ' closes instantly, /trigger ' + obj(menu, "last") + ' reopens.","color":"gray","italic":true}]',
            "",
        ]
    )
    out[f"{menu_dir_path(menu)}/open.mcfunction"] = "\n".join(lines)


def generate_close(menu: dict[str, Any], out: dict[str, str]) -> None:
    cart = (
        f"@e[type={container_entity_id(menu['container'])},"
        f"tag={menu_tag(menu)},sort=nearest,limit=1]"
    )
    lines = ["# Auto-generated close", "# Empty slots first so kill does not drop GUI items"]
    for slot in range(container_slot_count(menu["container"])):
        lines.append(f"execute as {cart} run {item_air_command('@s', slot)}")
    lines.extend(
        [
            f"kill @e[type={container_entity_id(menu['container'])},tag={menu_tag(menu)}]",
            clear_all_widgets(menu['namespace']),
            f"scoreboard players reset @s {obj(menu, 'menu_timer')}",
            f"scoreboard players reset @s {obj(menu, 'page')}",
        ]
    )
    for cmd in menu.get("on_close") or []:
        lines.append(str(cmd))
    lines.append("")
    out[f"{menu_dir_path(menu)}/close.mcfunction"] = "\n".join(lines)



WEATHER_PREDICATE_FIELDS = {
    # Java Edition has no `execute if weather` subcommand; the supported
    # check is the minecraft:weather_check predicate. raining=true also
    # passes during thunderstorms, so `rain` pins thundering=false.
    "clear": {"raining": False, "thundering": False},
    "rain": {"raining": True, "thundering": False},
    "thunder": {"raining": True, "thundering": True},
}


def generate_weather_predicates(menu: dict[str, Any], out: dict[str, str]) -> None:
    """Emit minecraft:weather_check predicate files for every weather value used."""
    used: set[str] = set()
    for w in all_widgets(menu):
        cond = w.get("condition")
        if cond and cond["type"] == "weather":
            used.add(cond["weather"])
    ns = menu["namespace"]
    for wx in sorted(used):
        data = {"type": "minecraft:weather_check", **WEATHER_PREDICATE_FIELDS[wx]}
        out[f"data/{ns}/predicate/guigen/weather_{wx}.json"] = (
            json.dumps(data, indent=2) + "\n"
        )


def generate_triggers(menu: dict[str, Any], out: dict[str, str]) -> None:
    """guikit-datapack v5 port: permission-0 player triggers.

    Mirrors guikit v5's play/open_trigger, play/last_trigger,
    play/close_trigger and api/close_all — adapted to guigenmc's
    single-static-menu model (the remembered state is the world-saved
    ``guigen_opened`` dummy score instead of guikit's pid-keyed storage).
    """
    open_fn = f"function {menu_function_prefix(menu)}/open"
    close_fn = f"function {menu_function_prefix(menu)}/close"

    out[f"{core_dir_path(menu)}/open_trigger.mcfunction"] = "\n".join(
        [
            "# Auto-generated — /trigger guigen.<ns>.open (guikit v5 port)",
            f"scoreboard players set @s {obj(menu, 'open')} 0",
            f"scoreboard players enable @s {obj(menu, 'open')}",
            open_fn,
            "",
        ]
    )
    out[f"{core_dir_path(menu)}/last_trigger.mcfunction"] = "\n".join(
        [
            "# Auto-generated — /trigger guigen.<ns>.last (guikit v5 port: play/last_trigger)",
            "# Reopens the menu if this player ever opened it. The remembered state",
            f"# ({obj(menu, 'opened')}) is world-saved, so it survives /reload — same property",
            "# guikit v5 gets from storage guikit:mem last.m<pid>.",
            f"scoreboard players set @s {obj(menu, 'last')} 0",
            f"scoreboard players enable @s {obj(menu, 'last')}",
            'execute unless score @s ' + obj(menu, "opened") + ' matches 1.. run tellraw @s [{"text":"[GUI-GENERATOR] ","color":"gray"},{"text":"You have not opened this menu yet.","color":"red"}]',
            f"execute unless score @s {obj(menu, 'opened')} matches 1.. run return 0",
            open_fn,
            "",
        ]
    )
    out[f"{core_dir_path(menu)}/close_trigger.mcfunction"] = "\n".join(
        [
            "# Auto-generated — /trigger guigen.<ns>.close (guikit v5 port: play/close_trigger)",
            "# Instant self-close — no operator permission needed.",
            f"scoreboard players set @s {obj(menu, 'close')} 0",
            f"scoreboard players enable @s {obj(menu, 'close')}",
            'execute unless score @s ' + obj(menu, "menu_timer") + ' matches 1.. run tellraw @s [{"text":"[GUI-GENERATOR] ","color":"gray"},{"text":"No open menu to close.","color":"red"}]',
            f"execute unless score @s {obj(menu, 'menu_timer')} matches 1.. run return 0",
            close_fn,
            "",
        ]
    )
    out[f"{core_dir_path(menu)}/close_all.mcfunction"] = "\n".join(
        [
            "# Auto-generated — guikit v5 port (api/close_all): closes every open menu (ops)",
            f"execute as @a[scores={{{obj(menu, 'menu_timer')}=1..}}] run {close_fn}",
            "",
        ]
    )


def generate_tags(menu: dict[str, Any], out: dict[str, str]) -> None:
    out["data/minecraft/tags/function/load.json"] = (
        json.dumps({"values": [f"{menu_core_prefix(menu)}/load"]}, indent=2) + "\n"
    )
    out["data/minecraft/tags/function/tick.json"] = (
        json.dumps({"values": [f"{menu_core_prefix(menu)}/tick"]}, indent=2) + "\n"
    )


def generate_pack_mcmeta(out: dict[str, str], description: str) -> None:
    # guikit-datapack commit 6a0b2f6 port: pack format 119 → 122
    data = {"pack": {"description": description, "min_format": 122, "max_format": 122}}
    out["pack.mcmeta"] = json.dumps(data, indent=2) + "\n"
