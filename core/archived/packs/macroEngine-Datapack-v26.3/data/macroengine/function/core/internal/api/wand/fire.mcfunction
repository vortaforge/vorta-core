# macroengine:api/wand/internal/fire [MACRO]
# Run the bind based on func or cmd field.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine _wand_current.func run function macroengine:core/internal/api/wand/call_func with storage macroengine:engine _wand_current
execute if data storage macroengine:engine _wand_current.cmd run function macroengine:core/internal/api/wand/call_cmd with storage macroengine:engine _wand_current
