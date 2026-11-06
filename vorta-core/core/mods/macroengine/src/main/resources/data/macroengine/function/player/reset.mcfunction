execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$data remove storage macroengine:engine players.$(player)
$data remove storage macroengine:engine cooldowns.$(player)
$advancement revoke @a[name=$(player),limit=1] from macroengine:hidden/root
$data modify storage macroengine:engine _pid_init_tmp set value {player:"$(player)"}
function macroengine:player/init with storage macroengine:engine _pid_init_tmp
