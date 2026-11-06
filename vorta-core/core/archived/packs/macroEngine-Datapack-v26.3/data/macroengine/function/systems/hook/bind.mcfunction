# ─────────────────────────────────────────────────────────────────
# macroengine:systems/hook/bind
# Binds a function or command to a specific event.
# Multiple binds can be added to the same event.
#
# INPUT (storage macroengine:input):
# event → event name: "player_join" | "player_death" | "player_respawn"
# "level_up" | "block_place" | "block_break" | "item_use"
# func → (optional) function to run — as the triggering player
# cmd → (optional) command to run — used if func is absent
#
# EXAMPLE:
# data modify storage macroengine:input event set value "player_death"
# data modify storage macroengine:input func set value "mypack:on_death"
# function macroengine:systems/hook/bind
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{hook:0b} run return 0
function macroengine:core/internal/systems/hook/bind_exec with storage macroengine:input {}
