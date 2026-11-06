# macroengine:api/cb/cancel_id
# ─────────────────────────────────────────────────────────────────
# Cancels the pending entries of ONE run_delayed / run_sequence call
# (selective version of api/cb/cancel, which clears the whole queue).
#
# INPUT  (storage macroengine:input cb):
#   id      (int)  — the cb_id returned by run_delayed / run_sequence  [REQUIRED, >= 1]
#
# OUTPUT (storage macroengine:output):
#   cb_cancelled  (int)  — how many queued entries were removed (0 if it already fired)
#
# The id is read as a number and compared on a scoreboard; it is never
# pasted into a macro, so a non-numeric id cannot inject anything.
#
# EXAMPLE:
#   data modify storage macroengine:input cb set value {cmds:["say a","say b"],interval:20}
#   function macroengine:api/cb/run_sequence
#   data modify storage macroengine:input cb.id set from storage macroengine:output cb_id
#   function macroengine:api/cb/cancel_id
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{cb:0b} run return 0
execute unless data storage macroengine:input cb.id run tellraw @s [{"text":"[MACROENGINE/cb] ","color":"#00AAAA","bold":true},{"text":"cb.id not set","color":"red"}]
execute unless data storage macroengine:input cb.id run return 0
execute store result score #cb_cid macroengine.tmp run data get storage macroengine:input cb.id
data remove storage macroengine:input cb
data modify storage macroengine:output cb_cancelled set value 0
execute unless score #cb_cid macroengine.tmp matches 1.. run return 0

scoreboard players set #cb_ccount macroengine.tmp 0
data modify storage macroengine:engine _cb_cwork set from storage macroengine:engine cb_queue
data modify storage macroengine:engine cb_queue set value []
execute if data storage macroengine:engine _cb_cwork[0] run function macroengine:core/internal/systems/cb/cancel_step
data remove storage macroengine:engine _cb_cwork
execute store result storage macroengine:output cb_cancelled int 1 run scoreboard players get #cb_ccount macroengine.tmp
