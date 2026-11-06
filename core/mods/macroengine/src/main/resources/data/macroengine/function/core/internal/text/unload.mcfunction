# macroengine:core/internal/text/unload
# Removes every storage entry owned by the text module.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data remove storage macroengine:text s
data remove storage macroengine:text out
data remove storage macroengine:text err
data remove storage macroengine:text_map lower
data remove storage macroengine:text_map upper
data remove storage macroengine:text_map digit
data remove storage macroengine:text_map deny_name
data remove storage macroengine:text_map deny_tag
data remove storage macroengine:text_map lower_full
data remove storage macroengine:text_map upper_full
data remove storage macroengine:text_map full
function macroengine:core/internal/text/reset
