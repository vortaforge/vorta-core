# macroengine:systems/flag/toggle_system - Toggle a built-in tick system on/off [MACRO]
# Usage: function macroengine:systems/flag/toggle_system {system:"time"}
# Valid systems: time | queue | player | hud | admin (anything else does nothing).
# Flips config.sys_<name> and applies it, so the config and the #sys_<name> score always agree.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$data modify storage macroengine:config in set value {system:"$(system)"}
execute if data storage macroengine:config in{system:"time"} run return run function macroengine:systems/flag/toggle_system/flip {key:"sys_time"}
execute if data storage macroengine:config in{system:"player"} run return run function macroengine:systems/flag/toggle_system/flip {key:"sys_player"}
execute if data storage macroengine:config in{system:"queue"} run return run function macroengine:systems/flag/toggle_system/flip {key:"sys_queue"}
execute if data storage macroengine:config in{system:"hud"} run return run function macroengine:systems/flag/toggle_system/flip {key:"sys_hud"}
execute if data storage macroengine:config in{system:"admin"} run return run function macroengine:systems/flag/toggle_system/flip {key:"sys_admin"}
return 0
