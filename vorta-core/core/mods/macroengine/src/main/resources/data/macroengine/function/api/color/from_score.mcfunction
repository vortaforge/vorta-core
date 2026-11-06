# macroengine:api/color/from_score [MACRO]
# Maps an integer score range to a color using a threshold table.
# Useful for health bars, progress displays, danger indicators.
#
# Threshold logic (low → high):
#   score < low_threshold  → low_color
#   score < mid_threshold  → mid_color
#   score >= mid_threshold → high_color
#
# Input (macro args):
#   objective     — scoreboard objective name
#   player        — player name, fake player name (include # prefix), or selector string
#   low_threshold — score below this → low_color
#   mid_threshold — score below this → mid_color (if >= low_threshold)
#   low_color     — color for low range  (e.g. "red")
#   mid_color     — color for mid range  (e.g. "yellow")
#   high_color    — color for high range (e.g. "green")
#
# Output → macroengine:output result
#   The matching color string.
#
# Usage:
#   function macroengine:api/color/from_score {objective:"health",player:"Steve",\
#     low_threshold:7,mid_threshold:14,\
#     low_color:"red",mid_color:"yellow",high_color:"green"}
#   data get storage macroengine:output result

# Default: high_color
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{color:0b} run return 0
$data modify storage macroengine:output result set value "$(high_color)"

# Override with low or mid if score is below threshold
$execute if score $(player) $(objective) matches ..$(low_threshold) run data modify storage macroengine:output result set value "$(low_color)"
$execute if score $(player) $(objective) matches $(low_threshold)..$(mid_threshold) run data modify storage macroengine:output result set value "$(mid_color)"