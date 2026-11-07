# ─────────────────────────────────────────────────────────────────
# macroengine:api/cmd/other/multi_cmd/utils/add_command
# Add a command to queue at runtime
#
# INPUT (storage macroengine:input):
# cmd or func → command/function to add
# ─────────────────────────────────────────────────────────────────

execute if data storage macroengine:engine modules{cmd:0b} run return 0
execute if score #perm_cmd macroengine.tick_flags matches 1 run data modify storage macroengine:perm_require in set value {perm:"cmd.other.multi_cmd.utils.add_command"}
execute if score #perm_cmd macroengine.tick_flags matches 1 unless function macroengine:api/perm/require run return 0
execute if data storage macroengine:input cmd run data modify storage macroengine:engine _mcmd_queue append value {}
execute if data storage macroengine:input cmd run data modify storage macroengine:engine _mcmd_queue[-1].cmd set from storage macroengine:input cmd

execute if data storage macroengine:input func run data modify storage macroengine:engine _mcmd_queue append value {}
execute if data storage macroengine:input func run data modify storage macroengine:engine _mcmd_queue[-1].func set from storage macroengine:input func