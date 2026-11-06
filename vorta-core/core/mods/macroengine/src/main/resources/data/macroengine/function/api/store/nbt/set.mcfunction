# macroengine:api/store/nbt/set [MACRO]
# Writes macroengine:store nbt.value to storage/path. Input (macro args): storage, path
# Passing the value through storage means any SNBT is safe: no escaping needed.
#
# Usage:
#   data modify storage macroengine:store nbt.value set value {hp:20,name:"Steve"}
#   function macroengine:api/store/nbt/set {storage:"mypack:data",path:"players.steve"}
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{store:0b} run return 0
$data modify storage $(storage) $(path) set from storage macroengine:store nbt.value
