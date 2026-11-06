# macroengine:core/internal/api/container/_slot [INTERNAL, MACRO: f]
# Like _num, plus a range check 0..255. RETURN 1 valid, 0 invalid.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set #macroengine.chk macroengine.tmp 0
$execute store result score #macroengine.chk macroengine.tmp run function macroengine:core/internal/api/container/_num {f:"$(f)"}
execute unless score #macroengine.chk macroengine.tmp matches 1.. run return 0
$execute store result score #ct_v macroengine.tmp run data get storage macroengine:container tmp.k.$(f)
execute unless score #ct_v macroengine.tmp matches 0..255 run return 0
return 1
