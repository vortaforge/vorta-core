# ======================================================================================
# macroengine:api/store/nbt/move [MACRO]
# Moves the value at <from> to <to> inside one storage, then removes <from>.
# Same contract as the other api/store/nbt/* helpers: raw macro arguments, so the caller
# must be trusted. Never pass chat/sign/book text into these arguments.
#
# INPUT (macro args): storage, from, to
#       The two paths must not overlap (do not move "a" into "a.b").
# RETURN 1 when the value was moved.
#        0 when <from> does not exist, or when <from> and <to> are the same path.
#
# Usage:
#   function macroengine:api/store/nbt/move {storage:"mypack:data",from:"draft",to:"final"}
# ======================================================================================

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{store:0b} run return 0
$execute unless data storage $(storage) $(from) run return 0

# Same-path guard: 'set from' reports failure when the value would not change.
data modify storage macroengine:engine _ext_mv set value {}
$data modify storage macroengine:engine _ext_mv.a set value "$(from)"
$data modify storage macroengine:engine _ext_mv.b set value "$(to)"
execute store success score #ext_mv_diff macroengine.tmp run data modify storage macroengine:engine _ext_mv.a set from storage macroengine:engine _ext_mv.b
data remove storage macroengine:engine _ext_mv
execute if score #ext_mv_diff macroengine.tmp matches 0 run return 0

$data modify storage $(storage) $(to) set from storage $(storage) $(from)
$data remove storage $(storage) $(from)
return 1
