# ======================================================================================
# macroengine:core/internal/systems/hook/on_bred_animals [INTERNAL]
# Advancement reward. @s = the player who breeds two animals.
# Revokes the advancement first (so it can fire again, even while the pack is closed or
# the hook module is off), then fires the "bred_animals" hook event.
# ======================================================================================

advancement revoke @s only macroengine:systems/hook/bred_animals
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{hook:0b} run return 0
data modify storage macroengine:engine _hook_fire_tmp set value {event:"bred_animals"}
function macroengine:core/internal/systems/hook/fire with storage macroengine:engine _hook_fire_tmp
data remove storage macroengine:engine _hook_fire_tmp
