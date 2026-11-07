data modify storage macroengine:engine config.module_cb set value 0b
function macroengine:core/config/apply

tellraw @s [{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"cb module: ","color":"aqua"},{"text":"disabled","color":"red"}]
