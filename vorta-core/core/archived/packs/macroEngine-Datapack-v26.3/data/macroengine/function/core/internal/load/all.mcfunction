# macroengine:core/internal/load/all — full init pipeline (no fork / rt_origin / confirm gates)

# forceload classic marker chunk (legacy features)
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
forceload add -30000000 1600

# Load scoreboards, storages and other systems
function macroengine:core/internal/load/loader/scoreboards
function macroengine:core/internal/load/loader/storages
function macroengine:core/internal/load/loader/other

# Re-apply config after storages (storages may reset defaults)
function macroengine:config
function macroengine:core/config/apply

# Run macroengine:core/internal/load/final function
function macroengine:core/internal/load/final
