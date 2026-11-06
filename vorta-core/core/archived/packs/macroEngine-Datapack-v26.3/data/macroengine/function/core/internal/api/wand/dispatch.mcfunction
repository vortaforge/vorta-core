# macroengine:api/wand/internal/dispatch
# Called as @s. Compare held items with the bind list.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:engine _wand_iter set from storage macroengine:engine wand_binds
execute if data storage macroengine:engine _wand_iter[0] run function macroengine:core/internal/api/wand/check_next
data remove storage macroengine:engine _wand_iter
data remove storage macroengine:engine _wand_current
