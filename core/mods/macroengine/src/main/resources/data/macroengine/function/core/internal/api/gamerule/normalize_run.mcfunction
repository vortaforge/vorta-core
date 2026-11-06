# macroengine:core/internal/api/gamerule/normalize_run  [INTERNAL]
# Called by normalize, which resets the text buffers afterwards.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:text s set from storage macroengine:input rule
data modify storage macroengine:text needle set value " "
data modify storage macroengine:text rep set value "_"
data modify storage macroengine:text n set value 0
function macroengine:core/internal/text/replace
execute if data storage macroengine:text err run return fail
data modify storage macroengine:text s set from storage macroengine:text out
function macroengine:core/internal/text/lower
execute if data storage macroengine:text err run return fail
data modify storage macroengine:input _gamerule_norm set from storage macroengine:text out
