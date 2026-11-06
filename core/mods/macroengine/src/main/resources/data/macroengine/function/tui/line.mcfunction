# macroengine:tui/line - one line of text for @s
#
# INPUT macroengine:tui in:
#   text    string with %tokens% (see api/store/render)           required
#   args    compound for %name% tokens                            optional
#   style   "info" | "warn" | "error" | "ok"  (prefix + colour)   optional, default: plain white
# Text comes from storage, so any characters are safe. Address another player with:
#   execute as Steve run function macroengine:tui/line
# RETURN 1 when a line was sent, 0 otherwise.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
function macroengine:core/internal/tui/render_text
execute unless data storage macroengine:tui t run return 0
execute if data storage macroengine:tui in{style:"info"} run return run tellraw @s ["",{"text":"[i] ","color":"aqua"},{"storage":"macroengine:tui","nbt":"t","interpret":true,"plain":false,"color":"gray"}]
execute if data storage macroengine:tui in{style:"warn"} run return run tellraw @s ["",{"text":"[!] ","color":"gold"},{"storage":"macroengine:tui","nbt":"t","interpret":true,"plain":false,"color":"yellow"}]
execute if data storage macroengine:tui in{style:"error"} run return run tellraw @s ["",{"text":"[x] ","color":"dark_red"},{"storage":"macroengine:tui","nbt":"t","interpret":true,"plain":false,"color":"red"}]
execute if data storage macroengine:tui in{style:"ok"} run return run tellraw @s ["",{"text":"[ok] ","color":"dark_green"},{"storage":"macroengine:tui","nbt":"t","interpret":true,"plain":false,"color":"green"}]
tellraw @s {"storage":"macroengine:tui","nbt":"t","interpret":false,"plain":true,"color":"white"}
return 1
