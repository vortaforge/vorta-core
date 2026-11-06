# macroengine:core/internal/api/item/hidden_flag_apply
# Internal — do not call directly. Second pass of api/item/hidden_flag.
# Expects: {player:"...",slot:"...",macroengine:{...}}

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
function macroengine:core/internal/api/item/_slot_map with storage macroengine:_item_tmp
function macroengine:core/internal/api/item/_custom_data_apply with storage macroengine:_item_tmp
