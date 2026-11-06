# ======================================================================================
# macroengine:input/give_anvil
# ======================================================================================
#
# Gives a marked paper item ready for anvil-rename input capture.
# Flow: the player opens an anvil, renames the item there and takes the result
# out with the cursor (click, not shift-click). That submits it. It does NOT work
# from the plain inventory screen: see macroengine:input/anvil for how the anvil
# is recognised.
#
# For a custom carrier item instead of paper, use give_anvil_custom
# (macro function) with: function macroengine:input/give_anvil_custom {item:"minecraft:item_id"}
#
# The un-renamed display name is stamped via minecraft:item_name so
# anvil_capture can report both the "before" and "after" name even though
# custom_name does not exist until the player actually renames it.
# ======================================================================================

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
give @s minecraft:paper[minecraft:custom_data={macroengine:{input:1b,inputItem:"anvil"}},minecraft:item_name={"text":"Anvil Input"}] 1
