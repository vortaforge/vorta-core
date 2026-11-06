# macroengine:setup — ordered load sequence (the old fake percentage output was removed:
# it printed 20+ console lines per load and reported nothing real).

# Initialization

# Step 0: Load Gate
function macroengine:gate/version
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0

# Step 0.5: Load Begin
function macroengine:gate/load_begin

# Step 1: Internal Text Module
function macroengine:core/internal/text/load

# Step 2: Player Enumeration
function macroengine:core/internal/player/enumerate

# Step 3: Player Resolution
function macroengine:core/internal/player/resolve

# Step 4: Player Initialization
function macroengine:core/internal/player/init

# Step 5: Core Main Load
function macroengine:core/internal/load/main

# Completion
function macroengine:gate/load_end
execute unless entity @a run say [MacroEngine] loaded
