execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:engine _ia_ubinds[0] run return 0

data modify storage macroengine:engine _ia_ucur set from storage macroengine:engine _ia_ubinds[0]
data remove storage macroengine:engine _ia_ubinds[0]

function macroengine:core/internal/api/interaction/unbind_check with storage macroengine:engine _ia_ufilter

function macroengine:core/internal/api/interaction/unbind_filter
data remove storage macroengine:engine _ia_ucur
