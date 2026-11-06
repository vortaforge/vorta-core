# macroengine:tui/header - title bar for @s, same look as api/toggle/show
#
# INPUT macroengine:tui in:  text (string with %tokens%, required), args (optional)
# RETURN 1 when sent, 0 otherwise.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
function macroengine:core/internal/tui/render_text
execute unless data storage macroengine:tui t run return 0
tellraw @s ["",{"text":"═══════ ","color":"dark_gray"},{"storage":"macroengine:tui","nbt":"t","interpret":true,"plain":false,"color":"aqua","bold":true},{"text":" ═══════","color":"dark_gray"}]
return 1
