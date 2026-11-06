# macroengine:tui/button - clickable [ label ] for @s that runs a function
#
# INPUT macroengine:tui in:
#   label   string with %tokens%                                   required
#   fn      function id "namespace:path" (no tags, no arguments)   required
#   hover   string with %tokens%                                   optional, default "Click to run"
#   args    compound for %name% tokens                             optional
# The click runs "/function <fn>" as the player, so the player needs permission to use /function
# (the toggle buttons of api/toggle/show work the same way). fn is checked with
# systems/validate/function_id before it reaches the macro line; label and hover stay in storage.
# RETURN 1 when sent, 0 when an input is missing or fn is not a valid function id.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:tui in.fn run return 0
data remove storage macroengine:validate in
data modify storage macroengine:validate in.value set from storage macroengine:tui in.fn
execute unless function macroengine:systems/validate/function_id run return 0
function macroengine:core/internal/tui/render_label
execute unless data storage macroengine:tui l run return 0
function macroengine:core/internal/tui/render_hover
data modify storage macroengine:tui b set value {}
data modify storage macroengine:tui b.fn set from storage macroengine:tui in.fn
function macroengine:core/internal/tui/button_send with storage macroengine:tui b
data remove storage macroengine:tui b
return 1
