$data remove storage macroengine:engine players.$(player)
$data remove storage macroengine:engine cooldowns.$(player)
$advancement revoke @a[name=$(player),limit=1] from macroengine:hidden/root
$data modify storage macroengine:engine _pid_init_tmp set value {player:"$(player)"}
function macroengine:player/init with storage macroengine:engine _pid_init_tmp
