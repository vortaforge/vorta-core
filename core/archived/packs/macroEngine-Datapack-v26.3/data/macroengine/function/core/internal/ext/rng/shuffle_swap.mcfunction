# ======================================================================================
# macroengine:core/internal/ext/rng/shuffle_swap [MACRO] [INTERNAL]
# $(i), $(j) are ints written by shuffle_step. Swaps two elements of _ext_shf.
# ======================================================================================

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$data modify storage macroengine:engine _ext_shf_t set from storage macroengine:engine _ext_shf[$(i)]
$data modify storage macroengine:engine _ext_shf[$(i)] set from storage macroengine:engine _ext_shf[$(j)]
$data modify storage macroengine:engine _ext_shf[$(j)] set from storage macroengine:engine _ext_shf_t
