data modify storage macroengine:engine config.module_cb set value 1b
function macroengine:core/config/apply

tellraw @s [{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"cb module: ","color":"aqua"},{"text":"enabled","color":"green"}]
