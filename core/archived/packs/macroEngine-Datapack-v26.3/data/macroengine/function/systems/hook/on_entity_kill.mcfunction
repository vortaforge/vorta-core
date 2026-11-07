# macroengine:systems/hook/on_entity_kill
# Reward: entity_kill advancement (player_killed_entity trigger)
execute if data storage macroengine:engine modules{hook:0b} run return 0
advancement revoke @s only macroengine:systems/hook/entity_kill
scoreboard players add @s macroengine.hook_entity_killed 1
