# macroengine:core/internal/api/block/_call [INTERNAL, MACRO: id, h]
# Runs the registered handler <h> at the block position. The handler id was validated at register.
# RETURN the handler's return value (1 = ok, 0 = deny), or -1 when no handler is registered.
$execute unless data storage macroengine:engine block_registry."$(id)".$(h) run return -1
$data modify storage macroengine:block tmp.p.fn set from storage macroengine:engine block_registry."$(id)".$(h)
return run function macroengine:core/internal/api/block/_run_fn with storage macroengine:block tmp.p
