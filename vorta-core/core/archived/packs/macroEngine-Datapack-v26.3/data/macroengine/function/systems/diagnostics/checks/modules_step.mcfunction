# macroengine:systems/diagnostics/checks/modules_step
# Internal: recursive walk over macroengine:diagnostics work.pending (one name per call).

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:diagnostics work.pending[0] run return 0

data modify storage macroengine:diagnostics work.cur set value {}
data modify storage macroengine:diagnostics work.cur.name set from storage macroengine:diagnostics work.pending[0]
data remove storage macroengine:diagnostics work.pending[0]
function macroengine:systems/diagnostics/checks/module_one with storage macroengine:diagnostics work.cur
function macroengine:systems/diagnostics/checks/modules_step
