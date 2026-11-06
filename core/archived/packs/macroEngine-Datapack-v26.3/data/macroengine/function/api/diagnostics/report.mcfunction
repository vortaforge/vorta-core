# macroengine:api/diagnostics/report
# Prints a human-readable health report to @s. Collects first (systems/diagnostics/collect), so the
# data is also left in macroengine:output diagnostics. Read-only: it never changes engine state.
#
# Usage:  function macroengine:api/diagnostics/report
# Caller: macroengine.admin tag required

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless entity @s[tag=macroengine.admin] run return 0

function macroengine:systems/diagnostics/collect

tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"━━━ Diagnostics ━━━━━━━━━━━━━━━━━","color":"#555555"}]
execute if data storage macroengine:output diagnostics{ok:1b} run tellraw @s ["",{"text":" status ","color":"gray"},{"text":"OK","color":"green","bold":true}]
execute if data storage macroengine:output diagnostics{ok:0b} run tellraw @s ["",{"text":" status ","color":"gray"},{"text":"ISSUES","color":"red","bold":true},{"text":" (","color":"#555555"},{"storage":"macroengine:output","nbt":"diagnostics.issue_count","color":"red"},{"text":")","color":"#555555"}]
execute if data storage macroengine:output diagnostics.issues[0] run tellraw @s ["",{"text":" issues ","color":"gray"},{"plain":true,"storage":"macroengine:output","nbt":"diagnostics.issues[]","separator":", ","interpret":false,"color":"red"}]
execute if data storage macroengine:output diagnostics.notices[0] run tellraw @s ["",{"text":" notices ","color":"gray"},{"plain":true,"storage":"macroengine:output","nbt":"diagnostics.notices[]","separator":", ","interpret":false,"color":"yellow"}]
tellraw @s ["",{"text":" modules ","color":"gray"},{"storage":"macroengine:output","nbt":"diagnostics.modules.enabled","color":"green"},{"text":" on / ","color":"gray"},{"storage":"macroengine:output","nbt":"diagnostics.modules.disabled","color":"red"},{"text":" off","color":"gray"}]
tellraw @s ["",{"text":" queue   ","color":"gray"},{"storage":"macroengine:output","nbt":"diagnostics.queue.size","color":"white"},{"text":" / cap ","color":"gray"},{"storage":"macroengine:output","nbt":"diagnostics.queue.cap","color":"white"}]
tellraw @s ["",{"text":" audit   ","color":"gray"},{"storage":"macroengine:output","nbt":"diagnostics.audit.count","color":"white"},{"text":" entries   log level ","color":"gray"},{"storage":"macroengine:output","nbt":"diagnostics.log.level","color":"white"},{"text":" (","color":"#555555"},{"storage":"macroengine:output","nbt":"diagnostics.log.buffered","color":"white"},{"text":" buffered)","color":"#555555"}]
tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━","color":"#555555"}]
