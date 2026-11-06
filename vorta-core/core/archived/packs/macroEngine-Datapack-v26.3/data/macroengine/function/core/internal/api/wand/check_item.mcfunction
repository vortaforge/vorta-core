# macroengine:api/wand/internal/check_item [MACRO]
# $(tag) → custom_data tag name
# If the item in the player's main hand has this tag, run the bind.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$execute if items entity @s weapon.mainhand *[minecraft:custom_data~{wand:"$(tag)"}] run function macroengine:core/internal/api/wand/fire with storage macroengine:engine _wand_current
