execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine pb_obj run scoreboard players operation $pb_mod macroengine.tmp = $epoch macroengine.time
execute if data storage macroengine:engine pb_obj run scoreboard players operation $pb_mod macroengine.tmp %= $pb_four macroengine.tmp
execute if data storage macroengine:engine pb_obj run execute if score $pb_mod macroengine.tmp matches 0 run execute as @a run function macroengine:systems/string/progress_bar_self with storage macroengine:engine {}
