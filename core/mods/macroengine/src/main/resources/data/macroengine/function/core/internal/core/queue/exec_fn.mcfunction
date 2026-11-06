# macroengine:core/queue/internal/exec_fn
# Runs a queued function in server (non-entity) context.
# Called with storage macroengine:engine _wq_job as macro source.
#
# Macro input:
#   fn — function path to call

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$data modify storage macroengine:engine _dispatch.func set value "$(fn)"
function #macroengine:internal/dispatch
