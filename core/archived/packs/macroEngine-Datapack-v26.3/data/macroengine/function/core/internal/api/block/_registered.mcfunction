# macroengine:core/internal/api/block/_registered [INTERNAL, MACRO: id]
# RETURN 1 when block_registry has this id.
$execute if data storage macroengine:engine block_registry."$(id)" run return 1
return 0
