execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$scoreboard players operation $ptd_val macroengine.tmp = @s $(name)

$scoreboard players set @s $(name) 0
$scoreboard players enable @s $(name)

$execute unless data storage macroengine:engine perm_triggers.$(name)[0] run return 0

$data modify storage macroengine:engine _ptd_binds set from storage macroengine:engine perm_triggers.$(name)

function macroengine:core/internal/api/perm/trigger/check_bind
data remove storage macroengine:engine _ptd_binds
data remove storage macroengine:engine _ptd_current
