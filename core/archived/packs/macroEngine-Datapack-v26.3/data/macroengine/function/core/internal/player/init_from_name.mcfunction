# macroengine:player/internal/init_from_name [MACRO]
# Relay: storage macroengine:names temp {NAME:"<player>"} → macroengine:player/init
# Called by on_player_join after macroengine:player/get_name populates macroengine:names temp.
# Bridges the NAME key to the player key expected by player/init.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$data modify storage macroengine:engine _pid_init_tmp set value {player:"$(NAME)"}
function macroengine:player/init with storage macroengine:engine _pid_init_tmp
data remove storage macroengine:engine _pid_init_tmp
