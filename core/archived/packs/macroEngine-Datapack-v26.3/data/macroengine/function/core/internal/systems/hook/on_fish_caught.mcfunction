# macroengine:systems/hook/internal/on_fish_caught
# @s = the fishing player
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players add @s macroengine.hook_fish 1
advancement revoke @s only macroengine:systems/hook/fish_caught
