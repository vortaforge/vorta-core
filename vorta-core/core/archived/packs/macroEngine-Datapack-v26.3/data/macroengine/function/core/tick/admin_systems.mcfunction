execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players enable @a[tag=macroengine.admin] macroengine_action
scoreboard players enable @a[tag=macroengine.admin] macroengine_run
function macroengine:core/internal/systems/geo/region_watch/tick_scan
