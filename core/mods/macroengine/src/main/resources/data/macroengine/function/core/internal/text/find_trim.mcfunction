# macroengine:core/internal/text/find_trim [INTERNAL] keep only the last |n| matches
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set #tx_m1 macroengine.tmp -1
scoreboard players operation #tx_drop macroengine.tmp = #tx_max macroengine.tmp
scoreboard players operation #tx_drop macroengine.tmp *= #tx_m1 macroengine.tmp
scoreboard players operation #tx_drop macroengine.tmp -= #tx_hits macroengine.tmp
scoreboard players operation #tx_drop macroengine.tmp *= #tx_m1 macroengine.tmp
execute if score #tx_drop macroengine.tmp matches 1.. run function macroengine:core/internal/text/find_drop
