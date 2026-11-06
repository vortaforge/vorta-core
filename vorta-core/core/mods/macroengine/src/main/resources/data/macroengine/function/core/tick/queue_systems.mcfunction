execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
function macroengine:core/lib/process_queue

# CB fire cooldown (see core/internal/systems/cb/process_step)
execute if score #cb_cd macroengine.tmp matches 1.. run scoreboard players remove #cb_cd macroengine.tmp 1

# CB delay queue — process pending command block executions
execute if data storage macroengine:engine modules{cb:1b} run execute if data storage macroengine:engine cb_queue[0] run function macroengine:core/internal/systems/cb/tick
