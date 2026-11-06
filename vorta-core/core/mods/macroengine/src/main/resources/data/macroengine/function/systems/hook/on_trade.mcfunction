# macroengine:systems/hook/on_trade
# Advancement reward: runs when villager_trade triggers.
# @s = the trading player

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{hook:0b} run return 0
advancement revoke @s only macroengine:systems/hook/trade
scoreboard players add @s macroengine.hook_traded 1
