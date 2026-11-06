# Hit any sign-like block
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if block ~ ~ ~ #minecraft:all_signs run return run function macroengine:input/private/sign_capture
execute if block ~ ~ ~ #minecraft:signs run return run function macroengine:input/private/sign_capture
execute if block ~ ~ ~ #minecraft:wall_signs run return run function macroengine:input/private/sign_capture
execute if block ~ ~ ~ #minecraft:standing_signs run return run function macroengine:input/private/sign_capture
execute if block ~ ~ ~ #minecraft:ceiling_hanging_signs run return run function macroengine:input/private/sign_capture
execute if block ~ ~ ~ #minecraft:wall_hanging_signs run return run function macroengine:input/private/sign_capture
# Explicit common ids (tag miss safety)
execute if block ~ ~ ~ minecraft:oak_sign run return run function macroengine:input/private/sign_capture
execute if block ~ ~ ~ minecraft:oak_wall_sign run return run function macroengine:input/private/sign_capture
execute if block ~ ~ ~ minecraft:birch_sign run return run function macroengine:input/private/sign_capture
execute if block ~ ~ ~ minecraft:birch_wall_sign run return run function macroengine:input/private/sign_capture
execute if block ~ ~ ~ minecraft:spruce_sign run return run function macroengine:input/private/sign_capture
execute if block ~ ~ ~ minecraft:spruce_wall_sign run return run function macroengine:input/private/sign_capture
execute if block ~ ~ ~ minecraft:dark_oak_sign run return run function macroengine:input/private/sign_capture
execute if block ~ ~ ~ minecraft:dark_oak_wall_sign run return run function macroengine:input/private/sign_capture
execute if block ~ ~ ~ minecraft:mangrove_sign run return run function macroengine:input/private/sign_capture
execute if block ~ ~ ~ minecraft:cherry_sign run return run function macroengine:input/private/sign_capture
execute if block ~ ~ ~ minecraft:bamboo_sign run return run function macroengine:input/private/sign_capture
execute if block ~ ~ ~ minecraft:crimson_sign run return run function macroengine:input/private/sign_capture
execute if block ~ ~ ~ minecraft:warped_sign run return run function macroengine:input/private/sign_capture

scoreboard players add @s macroengine.tmp 1
execute if score @s macroengine.tmp matches 40.. run return 0
execute positioned ^ ^ ^0.25 run function macroengine:input/private/sign_ray_loop
