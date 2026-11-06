# macroengine:core/internal/api/block/_call [INTERNAL, MACRO: id, h]
# Runs the registered handler <h> at the block position. The handler id was validated at register.
# RETURN the handler's return value (1 = ok, 0 = deny), or -1 when no handler is registered.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$execute unless data storage macroengine:engine block_registry."$(id)".$(h) run return -1
$data modify storage macroengine:block tmp.p.fn set from storage macroengine:engine block_registry."$(id)".$(h)
return run function macroengine:core/internal/api/block/_run_fn with storage macroengine:block tmp.p
