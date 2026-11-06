execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{trigger:0b} run return 0
execute unless data storage macroengine:engine trigger_binds run return 0

data modify storage macroengine:engine _tc_unbind set from storage macroengine:engine trigger_binds
data modify storage macroengine:engine trigger_binds set value []

$data modify storage macroengine:engine _tc_uval set value $(value)
function macroengine:core/internal/api/trigger/unbind_filter
data remove storage macroengine:engine _tc_unbind
data remove storage macroengine:engine _tc_uval