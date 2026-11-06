# macroengine:core/internal/api/store/_g_add [MACRO] [INTERNAL]
# #st_by holds the amount; a missing value counts as 0.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set #st_v macroengine.tmp 0
$execute store result score #st_v macroengine.tmp run data get storage macroengine:store g.$(name)
scoreboard players operation #st_v macroengine.tmp += #st_by macroengine.tmp
$execute store result storage macroengine:store g.$(name) int 1 run scoreboard players get #st_v macroengine.tmp
execute store result storage macroengine:store out.value int 1 run scoreboard players get #st_v macroengine.tmp
return run scoreboard players get #st_v macroengine.tmp
