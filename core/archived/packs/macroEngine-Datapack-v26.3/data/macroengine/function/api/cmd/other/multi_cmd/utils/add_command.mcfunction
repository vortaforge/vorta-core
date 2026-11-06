# ─────────────────────────────────────────────────────────────────
# macroengine:api/cmd/other/multi_cmd/utils/add_command
# Add a command to queue at runtime
#
# INPUT (storage macroengine:input):
# cmd or func → command/function to add
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{cmd:0b} run return 0
execute if score #perm_cmd macroengine.tick_flags matches 1 run data modify storage macroengine:perm_require in set value {perm:"cmd.other.multi_cmd.utils.add_command"}
execute if score #perm_cmd macroengine.tick_flags matches 1 unless function macroengine:api/perm/require run return 0
execute if data storage macroengine:input cmd run data modify storage macroengine:engine _mcmd_queue append value {}
execute if data storage macroengine:input cmd run data modify storage macroengine:engine _mcmd_queue[-1].cmd set from storage macroengine:input cmd

execute if data storage macroengine:input func run data modify storage macroengine:engine _mcmd_queue append value {}
execute if data storage macroengine:input func run data modify storage macroengine:engine _mcmd_queue[-1].func set from storage macroengine:input func