# ======================================================================================
# macroengine:core/internal/ext/player/toggle_var [MACRO] [INTERNAL]
# $(player), $(key) validated by player/toggle_var.
# ======================================================================================

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set #ext_tv macroengine.tmp 0
$execute if data storage macroengine:engine players.$(player).$(key) store result score #ext_tv macroengine.tmp run data get storage macroengine:engine players.$(player).$(key)
execute if score #ext_tv macroengine.tmp matches 0 run data modify storage macroengine:output result set value 1b
execute unless score #ext_tv macroengine.tmp matches 0 run data modify storage macroengine:output result set value 0b
$data modify storage macroengine:engine players.$(player).$(key) set from storage macroengine:output result
return run data get storage macroengine:output result
