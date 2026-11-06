# macroengine:systems/color/internal/validate_exec [MACRO]
# Internal — called by api/color/validate.
# Sets macroengine:output result to 1b if $(color) is a known named color,
# or if it begins with "#" (hex shorthand detection).
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$execute if data storage macroengine:engine color._names.$(color) run data modify storage macroengine:output result set value 1b

# Hex shorthand: valid if the string is non-empty and its first character is "#".
$data modify storage macroengine:engine _color_hex_probe set value "$(color)"
execute store result score #cv_hexlen macroengine.tmp run data get storage macroengine:engine _color_hex_probe
execute if score #cv_hexlen macroengine.tmp matches 1.. run data modify storage macroengine:engine _color_hex_probe set string storage macroengine:engine _color_hex_probe 0 1
execute if data storage macroengine:engine {_color_hex_probe:"#"} run data modify storage macroengine:output result set value 1b
data remove storage macroengine:engine _color_hex_probe
