# ============================================================
# macroengine:systems/uuid/from_entity
# Converts the current entity's (@s) UUID to a hex string
#
# USAGE:
# execute as <entity> run function macroengine:systems/uuid/from_entity
#
# OUTPUT:
# macroengine:output uuid → "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
#
# The result is written to macroengine:output uuid. macroengine:input is never touched.
# Direct NBT read on each call — always up to date
# Negative byte error is fixed (see extract_bytes)
# ============================================================

# Copy entity UUID as int[4] to working storage
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{uuid:0b} run return 0
data modify storage macroengine:uuid _work set from entity @s UUID

# Load four ints to scoreboard (without writing scores to entity)
execute store result score $uuid.0 macroengine.tmp run data get storage macroengine:uuid _work[0]
execute store result score $uuid.1 macroengine.tmp run data get storage macroengine:uuid _work[1]
execute store result score $uuid.2 macroengine.tmp run data get storage macroengine:uuid _work[2]
execute store result score $uuid.3 macroengine.tmp run data get storage macroengine:uuid _work[3]

# Split into 16 bytes → convert to hex chars → concatenate UUID string
function macroengine:core/internal/systems/uuid/extract_bytes
function macroengine:core/internal/systems/uuid/get_hexes with storage macroengine:uuid _tmp
function macroengine:core/internal/systems/uuid/concat with storage macroengine:uuid _tmp
