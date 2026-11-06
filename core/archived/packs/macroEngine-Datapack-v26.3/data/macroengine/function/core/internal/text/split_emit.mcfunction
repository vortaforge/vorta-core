# macroengine:core/internal/text/split_emit [INTERNAL] appends win to out unless it is empty and empties are dropped
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute store result score #tx_wl macroengine.tmp run data get storage macroengine:text win
execute if score #tx_wl macroengine.tmp matches 1.. run data modify storage macroengine:text out append from storage macroengine:text win
execute if score #tx_wl macroengine.tmp matches 0 if score #tx_keep macroengine.tmp matches 1 run data modify storage macroengine:text out append from storage macroengine:text win
