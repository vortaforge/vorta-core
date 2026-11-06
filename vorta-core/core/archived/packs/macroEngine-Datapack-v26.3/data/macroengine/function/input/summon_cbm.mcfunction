# Clear previous owner tag (multiplayer-safe)
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
tag @a remove macroengine.cbm_owner
tag @s add macroengine.cbm_owner

# Store owner UUID for later lookup
data modify storage macroengine:input cbm.owner set from entity @s UUID

# Position comes from @s, not from the command source: "execute as <player> run function ..." keeps the
# position of whoever typed the command, so the minecart has to be placed "at @s".
# Remove any nearby existing input minecart, then summon fresh
execute at @s run kill @e[type=minecraft:command_block_minecart,tag=macroengine_input,distance=..2]
execute at @s run summon minecraft:command_block_minecart ~ ~ ~ {OnGround:1b,UpdateLastExecution:1b,Command:"",Tags:["macroengine_input"],TrackOutput:1b}
