# macroengine:core/internal/text/find_hit [INTERNAL] record a match at #tx_i and skip past it
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:text idx append value 0
execute store result storage macroengine:text idx[-1] int 1 run scoreboard players get #tx_i macroengine.tmp
scoreboard players add #tx_hits macroengine.tmp 1
scoreboard players operation #tx_i macroengine.tmp += #tx_nlen macroengine.tmp
