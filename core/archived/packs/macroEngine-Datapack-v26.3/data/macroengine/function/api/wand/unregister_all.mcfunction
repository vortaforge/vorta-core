# macroengine:api/wand/unregister_all — Clears all wand binds.
execute if data storage macroengine:engine modules{wand:0b} run return 0
data modify storage macroengine:engine wand_binds set value []