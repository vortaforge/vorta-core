# ======================================================================================
# macroengine:systems/diagnostics/collect
# ======================================================================================
# Collects a health snapshot of the engine into storage. Read-only with respect to engine
# state: it never changes config, modules, queues, tags or permissions. It only writes its own
# output (macroengine:output diagnostics), scratch scores (#macroengine.dg_* in macroengine.tmp)
# and a scratch storage (macroengine:diagnostics work) that is removed again before returning.
#
# OUTPUT  macroengine:output diagnostics
#   ok            1b when issues is empty, else 0b
#   issue_count   length of issues
#   notice_count  length of notices
#   issues        list of problem codes, e.g. "module.mismatch:hook"   (see docs/diagnostics.md)
#   notices       list of informational codes, e.g. "security.dynamic_cmd_enabled"
#   modules       {enabled:int, disabled:int}
#   queue         {size:int, cap:int}
#   audit         {count:int}
#   log           {level:int, buffered:int}
# RETURN  number of issues (0 = healthy)
#
# Checks only what the engine itself stores. It does not measure CPU or tick time, and it does not
# repair anything: fixing is done with core/config/set, core/config/apply or a reload.
#
# Usage:
#   function macroengine:systems/diagnostics/collect
#   data get storage macroengine:output diagnostics.ok
# ======================================================================================

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0

data modify storage macroengine:output diagnostics set value {ok:1b,issue_count:0,notice_count:0,issues:[],notices:[],modules:{enabled:0,disabled:0},queue:{size:0,cap:0},audit:{count:0},log:{level:0,buffered:0}}
scoreboard players set #macroengine.dg_on macroengine.tmp 0
scoreboard players set #macroengine.dg_off macroengine.tmp 0
scoreboard players set #macroengine.dg_q macroengine.tmp 0
scoreboard players set #macroengine.dg_n macroengine.tmp 0

function macroengine:systems/diagnostics/checks/config
function macroengine:systems/diagnostics/checks/modules
function macroengine:systems/diagnostics/checks/queue
function macroengine:systems/diagnostics/checks/runtime

execute store result storage macroengine:output diagnostics.modules.enabled int 1 run scoreboard players get #macroengine.dg_on macroengine.tmp
execute store result storage macroengine:output diagnostics.modules.disabled int 1 run scoreboard players get #macroengine.dg_off macroengine.tmp
execute store result storage macroengine:output diagnostics.issue_count int 1 run data get storage macroengine:output diagnostics.issues
execute store result storage macroengine:output diagnostics.notice_count int 1 run data get storage macroengine:output diagnostics.notices
execute if data storage macroengine:output diagnostics.issues[0] run data modify storage macroengine:output diagnostics.ok set value 0b

data remove storage macroengine:diagnostics work
execute store result score #macroengine.dg_n macroengine.tmp run data get storage macroengine:output diagnostics.issues
return run scoreboard players get #macroengine.dg_n macroengine.tmp
