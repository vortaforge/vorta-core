# ======================================================================================
# macroengine:input/give_anvil_custom  [macro]
# ======================================================================================
#
# Same as give_anvil, but lets the caller choose the carrier item id.
# The carrier MUST be anvil-renameable (i.e. not a block that can't sit
# in an anvil input slot in survival — armor, tools, books, and most
# plain items all work; shulker boxes etc. also work).
#
# CALL: function macroengine:input/give_anvil_custom {item:"minecraft:iron_ingot"}
# ======================================================================================

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$give @s $(item)[minecraft:custom_data={macroengine:{input:1b,inputItem:"anvil"}},minecraft:item_name={"text":"Anvil Input"}] 1
