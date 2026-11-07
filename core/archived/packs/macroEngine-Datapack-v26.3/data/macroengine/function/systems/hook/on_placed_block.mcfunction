# Advancement reward: runs when placed_block triggers
# Find the newly placed block in the direction the player is looking

# Revoke advancement (so it can trigger again)
execute if data storage macroengine:engine modules{hook:0b} run return 0
advancement revoke @s only macroengine:systems/hook/placed_block

# Start raycast: begin from player's eyes
execute as @s at @s anchored eyes run function macroengine:systems/hook/raycast/start
