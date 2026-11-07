# macroengine:core/internal/load/all — full init pipeline (no fork / rt_origin / confirm gates)

# forceload classic marker chunk (legacy features)
forceload add -30000000 1600

# Load scoreboards, storages and other systems
function macroengine:core/internal/load/loader/scoreboards
function macroengine:core/internal/load/loader/storages
function macroengine:core/internal/load/loader/other

# Re-apply config after storages (storages may reset defaults)
function #macroengine:hook/config_init
function #macroengine:hook/config_apply

# Run macroengine:core/internal/load/final function
function macroengine:core/internal/load/final
