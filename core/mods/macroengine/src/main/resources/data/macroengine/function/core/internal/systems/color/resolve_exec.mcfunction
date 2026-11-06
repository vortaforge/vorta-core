# macroengine:systems/color/internal/resolve_exec [MACRO]
# Called with storage macroengine:engine color {} — reads palette.$(color).
# If the key exists in palette, copies it to macroengine:output result.
# Uses the outer $(color) macro arg captured by api/color/resolve.
# NOTE: This file is called with `with storage macroengine:engine color {}`
# so macro args come from the color compound (which contains "palette").
# The $(color) arg is forwarded from the parent macro frame.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$execute if data storage macroengine:engine color.palette.$(color) run data modify storage macroengine:output result set from storage macroengine:engine color.palette.$(color)
