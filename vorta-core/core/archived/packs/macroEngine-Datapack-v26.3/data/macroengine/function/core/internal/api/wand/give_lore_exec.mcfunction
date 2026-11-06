# macroengine:api/wand/internal/give_lore_exec [MACRO]
# INPUT (macro): $(player), $(tag), $(name), $(lore), $(color)
#
# Writes with lore directly to mainhand via item replace weapon.mainhand.
# Not give but item replace — places directly in slot 0 (mainhand).

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$item replace entity @a[name=$(player),limit=1] weapon.mainhand with minecraft:carrot_on_a_stick[minecraft:custom_data={wand:"$(tag)"},minecraft:item_name={"text":"$(name)"},minecraft:lore=[{"text":"$(lore)","italic":false,"color":"$(color)"}],minecraft:enchantment_glint_override=true]