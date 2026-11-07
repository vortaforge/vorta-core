# macroengine:systems/diagnostics/checks/modules_step
# Internal: recursive walk over macroengine:diagnostics work.pending (one name per call).

execute unless data storage macroengine:diagnostics work.pending[0] run return 0

data modify storage macroengine:diagnostics work.cur set value {}
data modify storage macroengine:diagnostics work.cur.name set from storage macroengine:diagnostics work.pending[0]
data remove storage macroengine:diagnostics work.pending[0]
function macroengine:systems/diagnostics/checks/module_one with storage macroengine:diagnostics work.cur
function macroengine:systems/diagnostics/checks/modules_step
