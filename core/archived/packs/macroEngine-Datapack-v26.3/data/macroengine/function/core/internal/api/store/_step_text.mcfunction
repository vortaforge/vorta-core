# macroengine:core/internal/api/store/_step_text [INTERNAL]
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute store result score #st_len macroengine.tmp run data get storage macroengine:store tmp.segs[0]
execute if score #st_len macroengine.tmp matches 1.. run data modify storage macroengine:store tmp.frags append from storage macroengine:store tmp.segs[0]
data remove storage macroengine:store tmp.segs[0]
scoreboard players set #st_mode macroengine.tmp 1
