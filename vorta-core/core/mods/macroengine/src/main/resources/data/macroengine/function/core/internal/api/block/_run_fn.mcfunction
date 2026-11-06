# macroengine:core/internal/api/block/_run_fn [INTERNAL, MACRO: x, y, z, fn]
# x, y, z are ints from the position check, fn passed function_id at register time.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$return run execute positioned $(x) $(y) $(z) run function $(fn)
