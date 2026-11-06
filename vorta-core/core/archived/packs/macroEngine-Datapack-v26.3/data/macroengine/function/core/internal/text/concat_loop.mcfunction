# macroengine:core/internal/text/concat_loop [INTERNAL]
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:text cl[0] run return 1
data modify storage macroengine:text s set string storage macroengine:text cl[0]
data remove storage macroengine:text cl[0]
execute store result score #tx_ok macroengine.tmp run function macroengine:core/internal/text/safe
execute if score #tx_ok macroengine.tmp matches 0 run data modify storage macroengine:text err set value "concat: an element contains a quote or backslash"
execute if score #tx_ok macroengine.tmp matches 0 run return 0
data modify storage macroengine:text pc append from storage macroengine:text s
return run function macroengine:core/internal/text/concat_loop
