# ─────────────────────────────────────────────────────────────────
# macroengine:api/cmd/other/multi_cmd/internal/exec_string
# Execute simple string command
# _mcmd_current is a plain string e.g. "say Hello"
# ─────────────────────────────────────────────────────────────────

# Wrap string into object
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:engine _mcmd_exec set value {}
data modify storage macroengine:engine _mcmd_exec.cmd set from storage macroengine:engine _mcmd_current

# Execute via macro
function macroengine:core/internal/api/cmd/other/multi_cmd/exec_macro with storage macroengine:engine _mcmd_exec

# Cleanup
data remove storage macroengine:engine _mcmd_exec
