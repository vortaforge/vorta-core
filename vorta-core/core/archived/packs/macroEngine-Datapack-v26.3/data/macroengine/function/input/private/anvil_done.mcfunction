# macroengine:input/private/anvil_done  [INTERNAL]
# @s = player, at @s, with the renamed carrier on the cursor. Capture, then end
# the session (capture fires the #macroengine:input/anvil hook).
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
function macroengine:input/private/anvil_capture
function macroengine:input/private/anvil_end
