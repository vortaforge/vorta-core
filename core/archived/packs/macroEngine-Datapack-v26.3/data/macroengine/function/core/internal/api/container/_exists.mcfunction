# macroengine:core/internal/api/container/_exists [INTERNAL, MACRO: x, y, z]
# RETURN 1 when the block is a container (has an Items list), else 0.
$execute if data block $(x) $(y) $(z) Items run return 1
return 0
