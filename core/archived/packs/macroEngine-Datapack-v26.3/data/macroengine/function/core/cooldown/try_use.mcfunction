# ======================================================================================
# macroengine:core/cooldown/try_use
# Atomic 'is it ready? then start it' for a cooldown. check + set in one call, so two
# callers in the same tick cannot both pass.
#
# INPUT  (storage macroengine:input cd):
#   player    the player name
#   key       the cooldown key
#   duration  ticks, >= 1 (clamped to 1..1000000000). Must be a real NBT number:
#             a string would be read as its length.
# OUTPUT macroengine:output result: 1b = was ready and is now armed, 0b = still active/invalid
# RETURN 1 when armed, 0 otherwise.
#
# Uses the same storage as core/cooldown/set|check|remaining|clear, so all of them keep
# working on a cooldown started here. A denied call never extends the cooldown.
# player and key are checked with systems/validate/safe_name before any macro line.
#
# Usage:
#   data modify storage macroengine:input cd set value {player:"Steve",key:"dash",duration:100}
#   execute if function macroengine:core/cooldown/try_use run say go
# ======================================================================================

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:output result set value 0b
execute unless data storage macroengine:input cd.player run return 0
execute unless data storage macroengine:input cd.key run return 0
execute unless data storage macroengine:input cd.duration run return 0
data remove storage macroengine:validate in
data modify storage macroengine:validate in.value set from storage macroengine:input cd.player
execute unless function macroengine:systems/validate/safe_name run return 0
data remove storage macroengine:validate in
data modify storage macroengine:validate in.value set from storage macroengine:input cd.key
execute unless function macroengine:systems/validate/safe_name run return 0

execute store result score #ext_cd_dur macroengine.tmp run data get storage macroengine:input cd.duration
execute if score #ext_cd_dur macroengine.tmp matches ..0 run scoreboard players set #ext_cd_dur macroengine.tmp 1
execute if score #ext_cd_dur macroengine.tmp matches 1000000001.. run scoreboard players set #ext_cd_dur macroengine.tmp 1000000000
execute store result score #ext_cd_now macroengine.tmp run scoreboard players get $epoch macroengine.time
scoreboard players operation #ext_cd_new macroengine.tmp = #ext_cd_now macroengine.tmp
scoreboard players operation #ext_cd_new macroengine.tmp += #ext_cd_dur macroengine.tmp
return run function macroengine:core/internal/ext/cooldown/try_use with storage macroengine:input cd
