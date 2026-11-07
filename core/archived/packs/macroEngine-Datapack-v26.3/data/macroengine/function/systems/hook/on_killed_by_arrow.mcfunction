# macroengine:systems/hook/on_killed_by_arrow
# Reward: killed_by_arrow advancement (entity_killed_player + killing_blow arrow)
execute if data storage macroengine:engine modules{hook:0b} run return 0
advancement revoke @s only macroengine:systems/hook/killed_by_arrow
scoreboard players add @s macroengine.hook_killed_by_arrow 1
