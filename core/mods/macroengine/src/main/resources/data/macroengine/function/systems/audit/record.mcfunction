# ======================================================================================
# macroengine:systems/audit/record
# ======================================================================================
# Appends one entry to the persistent audit trail (max 100 entries, oldest dropped).
# Separate from systems/log: that buffer is a 30-line display log; this one keeps
# structured, machine-readable entries (who, what, when).
#
# NOT A MACRO FUNCTION. Values are copied as DATA and never substituted into a command,
# so a hostile string cannot alter any command. Shown with interpret:false.
#
# INPUT  (storage macroengine:audit):
#   in.action   short action key, e.g. "perm.denied"      (default "unknown")
#   in.detail   free text / detail                         (default "")
# Actor = @s. Recorded automatically: t (tick epoch), pid + uuid (when @s is a player).
#
# USAGE:
#   data modify storage macroengine:audit in set value {action:"shop.buy"}
#   data modify storage macroengine:audit in.detail set value "diamond x3"
#   function macroengine:systems/audit/record
#
# KNOWN LIMIT: no de-duplication. A caller that can trigger record in a loop can push
# older entries out of the 100-entry buffer. Rate-limit such callers with
# macroengine:systems/rate_limit/check.
# ======================================================================================

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{audit:0b} run return 0
data modify storage macroengine:audit entry set value {action:"unknown",detail:""}
execute if data storage macroengine:audit in.action run data modify storage macroengine:audit entry.action set from storage macroengine:audit in.action
execute if data storage macroengine:audit in.detail run data modify storage macroengine:audit entry.detail set from storage macroengine:audit in.detail
execute store result storage macroengine:audit entry.t int 1 run scoreboard players get $epoch macroengine.time
execute if entity @s[type=player] store result storage macroengine:audit entry.pid int 1 run scoreboard players get @s macroengine.pid
execute if entity @s[type=player] run data modify storage macroengine:audit entry.uuid set from entity @s UUID

execute unless data storage macroengine:audit entries run data modify storage macroengine:audit entries set value []
data modify storage macroengine:audit entries append from storage macroengine:audit entry

execute store result score #macroengine.au_n macroengine.tmp run data get storage macroengine:audit entries
execute if score #macroengine.au_n macroengine.tmp matches 101.. run data remove storage macroengine:audit entries[0]

data remove storage macroengine:audit entry
data remove storage macroengine:audit in
