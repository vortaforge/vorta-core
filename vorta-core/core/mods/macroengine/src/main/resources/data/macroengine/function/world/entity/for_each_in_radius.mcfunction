# ─────────────────────────────────────────────────────────────────
# macroengine:world/entity/for_each_in_radius
# Runs a function as every entity of a given type within radius
# of the named player.
#
# INPUT : $(player) → player name (origin)
#         $(type)   → entity type (e.g. "minecraft:zombie")
#         $(radius) → search radius in blocks
#         $(func)   → function to run as each entity (at its position)
#
# EXAMPLE:
# function macroengine:world/entity/for_each_in_radius {player:"Steve",type:"minecraft:zombie",radius:10,func:"mypack:on_zombie"}
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$data modify storage macroengine:engine _dispatch.func set value "$(func)"
$execute as @a[name=$(player),limit=1] at @s run execute as @e[type=$(type),distance=..$(radius)] at @s run function #macroengine:internal/dispatch
