# macroengine:core/internal/api/container/_pos [INTERNAL, MACRO: x, y, z (input key names)]
# Validates three coordinate keys of macroengine:input as ints in world range.
# RETURN 1 valid, 0 invalid.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set #macroengine.chk macroengine.tmp 0
$execute store result score #macroengine.chk macroengine.tmp run function macroengine:core/internal/api/container/_num {f:"$(x)"}
execute unless score #macroengine.chk macroengine.tmp matches 1.. run return 0
scoreboard players set #macroengine.chk macroengine.tmp 0
$execute store result score #macroengine.chk macroengine.tmp run function macroengine:core/internal/api/container/_num {f:"$(y)"}
execute unless score #macroengine.chk macroengine.tmp matches 1.. run return 0
scoreboard players set #macroengine.chk macroengine.tmp 0
$execute store result score #macroengine.chk macroengine.tmp run function macroengine:core/internal/api/container/_num {f:"$(z)"}
execute unless score #macroengine.chk macroengine.tmp matches 1.. run return 0
$execute store result score #ct_v macroengine.tmp run data get storage macroengine:container tmp.k.$(x)
execute unless score #ct_v macroengine.tmp matches -30000000..30000000 run return 0
$execute store result score #ct_v macroengine.tmp run data get storage macroengine:container tmp.k.$(y)
execute unless score #ct_v macroengine.tmp matches -2048..2047 run return 0
$execute store result score #ct_v macroengine.tmp run data get storage macroengine:container tmp.k.$(z)
execute unless score #ct_v macroengine.tmp matches -30000000..30000000 run return 0
return 1
