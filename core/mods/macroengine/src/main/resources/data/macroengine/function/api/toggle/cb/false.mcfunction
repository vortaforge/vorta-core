execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:engine config.module_cb set value 0b
function macroengine:core/config/apply

tellraw @s [{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"cb module: ","color":"aqua"},{"text":"disabled","color":"red"}]
