# macroengine:systems/sound/play_at
# Coordinate-targeted playsound. Anyone within range of (x,y,z) hears it.
# Use for world-position sounds (explosions, ambient effects, etc.).
#
# Input  (macroengine:input sound):
#   sound      — sound event ID
#   category   — source category
#   x, y, z    — world coordinates (int or double)
#   volume     — float ≥ 0        (controls audible radius: radius = 16*volume blocks)
#   pitch      — float 0.0–2.0
#   min_volume — float 0.0–1.0    (audibility outside radius; 0.0 = silent outside)
#
# Usage:
#   data modify storage macroengine:input sound set value \
#     {sound:"minecraft:block.note_block.bell",category:"block",\
#      x:0,y:64,z:0,volume:1.0f,pitch:1.0f,min_volume:0.0f}
#   function macroengine:systems/sound/play_at with storage macroengine:input sound

execute if data storage macroengine:engine modules{sound:0b} run return 0
$playsound $(sound) $(category) @a $(x) $(y) $(z) $(volume) $(pitch) $(min_volume)
