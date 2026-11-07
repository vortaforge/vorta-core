# macroEngine player module — drop all state tags before this tick's
# detection runs. Tags are re-added below when their condition holds.

tag @s remove player_action.moving

# Movement-state tags
tag @s remove player_action.flying
tag @s remove player_action.walking
tag @s remove player_action.falling
tag @s remove player_action.climbing
tag @s remove player_action.elyra_flying
tag @s remove player_action.swimming
tag @s remove player_action.sneaking
tag @s remove player_action.sprinting

# Mount tags
tag @s remove player_action.riding_pig
tag @s remove player_action.riding_boat
tag @s remove player_action.riding_mule
tag @s remove player_action.riding_llama
tag @s remove player_action.riding_horse
tag @s remove player_action.riding_donkey
tag @s remove player_action.riding_strider
tag @s remove player_action.riding_minecart
