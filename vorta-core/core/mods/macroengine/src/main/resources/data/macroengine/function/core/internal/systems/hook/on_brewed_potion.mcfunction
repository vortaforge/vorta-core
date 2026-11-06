# ======================================================================================
# macroengine:core/internal/systems/hook/on_brewed_potion [INTERNAL]
# Advancement reward. @s = the player who takes a potion out of a brewing stand.
# Revokes the advancement first (so it can fire again, even while the pack is closed or
# the hook module is off), then fires the "brewed_potion" hook event.
# ======================================================================================

advancement revoke @s only macroengine:systems/hook/brewed_potion
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{hook:0b} run return 0
data modify storage macroengine:engine _hook_fire_tmp set value {event:"brewed_potion"}
function macroengine:core/internal/systems/hook/fire with storage macroengine:engine _hook_fire_tmp
data remove storage macroengine:engine _hook_fire_tmp
