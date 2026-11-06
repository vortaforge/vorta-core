# macroengine:core/lib/batch/internal/add_func [MACRO]
# INPUT: $(id) — func is NBT-copied from macroengine:input, not macro-spliced
# Called with func field guaranteed.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$data modify storage macroengine:engine batches.$(id).items append value {func:""}
$data modify storage macroengine:engine batches.$(id).items[-1].func set from storage macroengine:input func
