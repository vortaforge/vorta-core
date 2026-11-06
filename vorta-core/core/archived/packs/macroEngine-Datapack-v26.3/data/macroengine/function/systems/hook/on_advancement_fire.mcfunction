# ─────────────────────────────────────────────────────────────────
# macroengine:systems/hook/on_advancement_fire
# Called from the user's own advancement reward function.
# Fires an event in "advancement:<id>" format.
#
# INPUT (storage macroengine:input):
# advancement → advancement ID (e.g. "story/mine_stone")
#
# USAGE:
# 1) Define a function as the reward in your advancement JSON:
# "rewards": {"function": "mypack:advancements/mine_stone"}
#
# 2) Inside that function:
# data modify storage macroengine:input advancement set value "story/mine_stone"
# function macroengine:systems/hook/on_advancement_fire
#
# 3) Hook bind:
# data modify storage macroengine:input event set value "advancement:story/mine_stone"
# data modify storage macroengine:input func set value "mypack:on_first_mine"
# function macroengine:systems/hook/bind
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{hook:0b} run return 0
function macroengine:core/internal/systems/hook/on_advancement_fire with storage macroengine:input {}
