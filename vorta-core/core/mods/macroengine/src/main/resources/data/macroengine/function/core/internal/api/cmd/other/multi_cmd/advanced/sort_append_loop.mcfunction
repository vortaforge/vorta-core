# ─────────────────────────────────────────────────────────────────
# macroengine:api/cmd/other/multi_cmd/advanced/internal/sort_append_loop
# Recursive: drain _sort_tmp into _mcmd_queue one item at a time.
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:engine _sort_tmp[0] run return 0

data modify storage macroengine:engine _mcmd_queue append from storage macroengine:engine _sort_tmp[0]
data remove storage macroengine:engine _sort_tmp[0]

function macroengine:core/internal/api/cmd/other/multi_cmd/advanced/sort_append_loop
