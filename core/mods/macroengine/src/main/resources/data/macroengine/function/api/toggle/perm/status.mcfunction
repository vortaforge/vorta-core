# macroengine:api/toggle/perm/status
# Prints the permission switches to @s (enforcement, per-command permissions, default).

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0

tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"perm_enforce=","color":"aqua"},{"nbt":"config.perm_enforce","storage":"macroengine:engine"},{"text":"  perm_cmd=","color":"aqua"},{"nbt":"config.perm_cmd","storage":"macroengine:engine"},{"text":"  perm_default=","color":"aqua"},{"nbt":"perm_default","storage":"macroengine:engine"},{"text":"  module_perm=","color":"aqua"},{"nbt":"config.module_perm","storage":"macroengine:engine"}]
