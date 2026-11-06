# ======================================================================================
# macroengine:player/add_var_clamped
# Adds a delta to a player variable and clamps the result to [min, max] in one step
# (player/increment and player/clamp_var would need two calls and can overshoot between them).
# A missing variable counts as 0.
#
# INPUT  (storage macroengine:input pvar):  player, key, delta, min, max
#   delta, min and max must be real NBT numbers (a string would be read as its length).
#   They are limited to +-1000000000, so the sum can never overflow a score.
#   min > max is rejected.
# OUTPUT macroengine:output result (int): the new stored value
# RETURN 1 when applied, 0 when the input is invalid (nothing is changed).
#
# Same storage as player/get_var|set_var. player and key are checked with
# systems/validate/safe_name before any macro line.
#
# Usage:
#   data modify storage macroengine:input pvar set value {player:"Steve",key:"coins",delta:-5,min:0,max:9999}
#   function macroengine:player/add_var_clamped
# ======================================================================================

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:input pvar.player run return 0
execute unless data storage macroengine:input pvar.key run return 0
execute unless data storage macroengine:input pvar.delta run return 0
execute unless data storage macroengine:input pvar.min run return 0
execute unless data storage macroengine:input pvar.max run return 0
data remove storage macroengine:validate in
data modify storage macroengine:validate in.value set from storage macroengine:input pvar.player
execute unless function macroengine:systems/validate/safe_name run return 0
data remove storage macroengine:validate in
data modify storage macroengine:validate in.value set from storage macroengine:input pvar.key
execute unless function macroengine:systems/validate/safe_name run return 0

execute store result score #ext_pv_d macroengine.tmp run data get storage macroengine:input pvar.delta
execute store result score #ext_pv_min macroengine.tmp run data get storage macroengine:input pvar.min
execute store result score #ext_pv_max macroengine.tmp run data get storage macroengine:input pvar.max
execute if score #ext_pv_min macroengine.tmp > #ext_pv_max macroengine.tmp run return 0
execute if score #ext_pv_d macroengine.tmp matches 1000000001.. run scoreboard players set #ext_pv_d macroengine.tmp 1000000000
execute if score #ext_pv_d macroengine.tmp matches ..-1000000001 run scoreboard players set #ext_pv_d macroengine.tmp -1000000000
execute if score #ext_pv_min macroengine.tmp matches 1000000001.. run scoreboard players set #ext_pv_min macroengine.tmp 1000000000
execute if score #ext_pv_min macroengine.tmp matches ..-1000000001 run scoreboard players set #ext_pv_min macroengine.tmp -1000000000
execute if score #ext_pv_max macroengine.tmp matches 1000000001.. run scoreboard players set #ext_pv_max macroengine.tmp 1000000000
execute if score #ext_pv_max macroengine.tmp matches ..-1000000001 run scoreboard players set #ext_pv_max macroengine.tmp -1000000000
function macroengine:core/internal/ext/player/add_var_clamped with storage macroengine:input pvar
return 1
