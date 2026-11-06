execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{interaction:0b} run return 0
execute unless data storage macroengine:engine interaction_binds.attack[0] run return 0

data modify storage macroengine:engine _ia_ubinds set from storage macroengine:engine interaction_binds.attack
data modify storage macroengine:engine interaction_binds.attack set value []
$data modify storage macroengine:engine _ia_ufilter set value {tag:"$(tag)", func:"$(func)", list:"attack"}
function macroengine:core/internal/api/interaction/unbind_filter
data remove storage macroengine:engine _ia_ubinds
data remove storage macroengine:engine _ia_ufilter