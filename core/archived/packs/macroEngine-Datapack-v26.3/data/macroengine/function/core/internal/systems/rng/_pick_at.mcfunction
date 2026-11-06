# macroengine:core/internal/systems/rng/_pick_at [MACRO]
# INPUT: $(index) — position already chosen by systems/rng/pick

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$data modify storage macroengine:output result set from storage macroengine:engine _rng_list[$(index)]
