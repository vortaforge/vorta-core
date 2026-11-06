# macroengine:api/store/nbt/copy [MACRO]
# Copies one NBT value to another place.
# Input (macro args): from, from_path, to, to_path   (from/to are storage ids)
#
# Usage:  function macroengine:api/store/nbt/copy {from:"a:b",from_path:"x",to:"c:d",to_path:"y"}
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{store:0b} run return 0
$data modify storage $(to) $(to_path) set from storage $(from) $(from_path)
