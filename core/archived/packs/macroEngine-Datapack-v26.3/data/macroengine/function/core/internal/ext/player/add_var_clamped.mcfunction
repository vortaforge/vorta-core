# ======================================================================================
# macroengine:core/internal/ext/player/add_var_clamped [MACRO] [INTERNAL]
# $(player), $(key) validated; #ext_pv_d / _min / _max prepared by player/add_var_clamped.
# ======================================================================================

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set #ext_pv macroengine.tmp 0
$execute if data storage macroengine:engine players.$(player).$(key) store result score #ext_pv macroengine.tmp run data get storage macroengine:engine players.$(player).$(key)

# Clamp the current value first, so value + delta can never leave the +-2e9 range.
execute if score #ext_pv macroengine.tmp < #ext_pv_min macroengine.tmp run scoreboard players operation #ext_pv macroengine.tmp = #ext_pv_min macroengine.tmp
execute if score #ext_pv macroengine.tmp > #ext_pv_max macroengine.tmp run scoreboard players operation #ext_pv macroengine.tmp = #ext_pv_max macroengine.tmp
scoreboard players operation #ext_pv macroengine.tmp += #ext_pv_d macroengine.tmp
execute if score #ext_pv macroengine.tmp < #ext_pv_min macroengine.tmp run scoreboard players operation #ext_pv macroengine.tmp = #ext_pv_min macroengine.tmp
execute if score #ext_pv macroengine.tmp > #ext_pv_max macroengine.tmp run scoreboard players operation #ext_pv macroengine.tmp = #ext_pv_max macroengine.tmp

$execute store result storage macroengine:engine players.$(player).$(key) int 1 run scoreboard players get #ext_pv macroengine.tmp
execute store result storage macroengine:output result int 1 run scoreboard players get #ext_pv macroengine.tmp
