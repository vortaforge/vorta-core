"""Core tick generator."""

from __future__ import annotations

from typing import Any

from ..components import clear_all_widgets, clear_by_type, clear_by_type_id
from ..models import (
    all_widgets,
    container_entity_id,
    interactive_widgets,
    menu_click_prefix,
    menu_core_prefix,
    menu_function_prefix,
    menu_tag,
    obj,
    resolved_action_id,
)
from ..paths import core_dir_path
from .handlers import cd_score

VACUUM_TYPES = ["label", "separator", "progress"]


def dropped_item_kill(menu: dict[str, Any], key: str) -> str:
    """Kill dropped GUI items of *this* pack only (pack-scoped custom_data)."""
    ns = menu["namespace"]
    inner = "{widget:1,pack:\"" + ns + "\"}"
    return (
        "kill @e[type=minecraft:item,nbt={Item:{components:{"
        + key
        + ":{guigen:"
        + inner
        + "}}}}]"
    )


def detect_block(menu: dict[str, Any], widget_type: str, widget_id: str, handler_fn: str) -> list[str]:
    return [
        f"execute as @a[scores={{{obj(menu, 'menu_timer')}=1..}}] store success score @s {obj(menu, 'click')} "
        f"run {clear_by_type_id(widget_type, widget_id, 1, menu['namespace'])}",
        f"execute as @a[scores={{{obj(menu, 'click')}=1}}] at @s run function {handler_fn}",
        f"scoreboard players reset @a[scores={{{obj(menu, 'click')}=1}}] {obj(menu, 'click')}",
        "",
    ]


def generate_tick(menu: dict[str, Any], out: dict[str, str]) -> None:
    entity = container_entity_id(menu["container"])
    cart = f"@e[type={entity},tag={menu_tag(menu)},sort=nearest,limit=1]"

    lines = [
        "# Auto-generated core tick",
        "# Timer",
        f"execute as @a[scores={{{obj(menu, 'menu_timer')}=1..}}] run scoreboard players remove @s {obj(menu, 'menu_timer')} 1",
        f"execute as @a[scores={{{obj(menu, 'menu_timer')}=0}}] at @s run function {menu_function_prefix(menu)}/close",
        "",
        "# Player triggers — guikit-datapack v5 port (core/tick enables and",
        "# dispatches guigen.<ns>.open/last/close; permission level 0)",
        f"scoreboard players enable @a {obj(menu, 'open')}",
        f"scoreboard players enable @a {obj(menu, 'last')}",
        f"scoreboard players enable @a {obj(menu, 'close')}",
        f"execute as @a[scores={{{obj(menu, 'open')}=1..}}] at @s run function {menu_core_prefix(menu)}/open_trigger",
        f"execute as @a[scores={{{obj(menu, 'last')}=1..}}] at @s run function {menu_core_prefix(menu)}/last_trigger",
        f"execute as @a[scores={{{obj(menu, 'close')}=1..}}] run function {menu_core_prefix(menu)}/close_trigger",
        "",
        "# Cooldown tick-down",
    ]

    cd_scores: list[str] = []
    for w in interactive_widgets(menu):
        ticks = int(w.get("cooldown_ticks") or 0)
        if ticks > 0:
            sc = cd_score(resolved_action_id(w), menu)
            if sc not in cd_scores:
                cd_scores.append(sc)
    for sc in cd_scores:
        lines.append(f"execute as @a[scores={{{sc}=1..}}] run scoreboard players remove @s {sc} 1")
    if cd_scores:
        lines.append("")

    if menu.get("follow", True):
        y_off = float(menu["container"].get("y_offset") or 0.0)
        tp_target = f"~ ~{y_off} ~" if y_off else "~ ~ ~"
        lines.extend(
            [
                "# Follow (cart is kept on the player; distance_close cannot be exceeded)",
                f"execute as @a[scores={{{obj(menu, 'menu_timer')}=1..}}] at @s as {cart} run tp @s {tp_target}",
                f"execute as @a[scores={{{obj(menu, 'menu_timer')}=1..}}] at @s "
                f"unless entity @e[type={entity},tag={menu_tag(menu)},limit=1] "
                f"run function {menu_function_prefix(menu)}/close",
                "",
            ]
        )
    else:
        dist = menu.get("distance_close", 32)
        lines.extend(
            [
                "# Not following — enforce distance_close and cart-presence",
                f"execute as @a[scores={{{obj(menu, 'menu_timer')}=1..}}] at @s "
                f"unless entity @e[type={entity},tag={menu_tag(menu)},limit=1] "
                f"run function {menu_function_prefix(menu)}/close",
                f"execute as @a[scores={{{obj(menu, 'menu_timer')}=1..}}] at @s "
                f"unless entity @e[type={entity},tag={menu_tag(menu)},distance=..{dist},limit=1] "
                f"run function {menu_function_prefix(menu)}/close",
                "",
            ]
        )

    for w in all_widgets(menu):
        if w.get("toggle") and w["toggle"].get("tick_while_on"):
            for cmd in w["toggle"]["tick_while_on"]:
                lines.append(f"execute as @a[scores={{{w['toggle']['score']}=1}}] run {cmd}")
            lines.append("")

    lines.extend(["# Click detection", ""])

    seen: set[str] = set()
    for w in interactive_widgets(menu):
        aid = resolved_action_id(w)
        if aid in seen:
            continue
        seen.add(aid)
        handler = f"{menu_click_prefix(menu)}/{aid}"
        lines.extend(detect_block(menu, w["kind"], aid, handler))

    lines.extend(["# Vacuum GUI items from player", ""])
    present_kinds = {w["kind"] for w in all_widgets(menu)}
    present_kinds.add("separator")
    for kind in VACUUM_TYPES:
        if kind in present_kinds:
            lines.append(
                f"execute as @a[scores={{{obj(menu, 'menu_timer')}=1..}}] run {clear_by_type(kind, menu['namespace'])}"
            )
    lines.append(f"execute as @a[scores={{{obj(menu, 'menu_timer')}=1..}}] run {clear_all_widgets(menu['namespace'])}")

    lines.extend(
        [
            "",
            "# Restore layout every tick",
            f"execute as @a[scores={{{obj(menu, 'menu_timer')}=1..}}] at @s "
            f"run function {menu_function_prefix(menu)}/fill",
            "",
            "# Kill dropped GUI items",
            dropped_item_kill(menu, '"minecraft:custom_data"'),
            dropped_item_kill(menu, "custom_data"),
            "",
        ]
    )

    out[f"{core_dir_path(menu)}/tick.mcfunction"] = "\n".join(lines)
