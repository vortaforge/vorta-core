$execute if data storage macroengine:engine once_keys.$(key) run return 0

$data modify storage macroengine:cmd_gate in.cmd set value "$(cmd)"
execute unless function macroengine:systems/cmd_gate/check run return 0
$data modify storage macroengine:engine once_keys.$(key) set value 1b

$$(cmd)