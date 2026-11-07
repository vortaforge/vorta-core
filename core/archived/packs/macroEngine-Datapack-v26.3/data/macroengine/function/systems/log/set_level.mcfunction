# macroengine:systems/log/set_level
# Usage: $function macroengine:systems/log/set_level {level:3}
# Sets the active log level:
#   0 = off
#   1 = error only
#   2 = warn + error
#   3 = info + warn + error  (default)
#   4 = debug (all)
execute if data storage macroengine:engine modules{log:0b} run return 0
execute unless entity @s[tag=macroengine.admin] run return 0
$scoreboard players set #macroengine.log_level macroengine.log_level $(level)
execute store result storage macroengine:engine config.log_level int 1 run scoreboard players get #macroengine.log_level macroengine.log_level
$tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"Log level set to ","color":"gray"},{"text":"$(level)","color":"white","bold":true}]
