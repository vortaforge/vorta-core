# macroengine:core/internal/api/container/_size_pick [INTERNAL, MACRO: src, ovr]
# Sets #ct_size (macroengine.tmp) from macroengine:input <ovr> when given, else from the block
# at macroengine:container <src> {x,y,z}. RETURN 1 when 1..256, else 0.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set #ct_size macroengine.tmp 0
$execute if data storage macroengine:input $(ovr) store result score #ct_size macroengine.tmp run data get storage macroengine:input $(ovr)
$execute unless data storage macroengine:input $(ovr) store result score #ct_size macroengine.tmp run function macroengine:core/internal/api/container/_size with storage macroengine:container $(src)
execute unless score #ct_size macroengine.tmp matches 1..256 run return 0
return 1
