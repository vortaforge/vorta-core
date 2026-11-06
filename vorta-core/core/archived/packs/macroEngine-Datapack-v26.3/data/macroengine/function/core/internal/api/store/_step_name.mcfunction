# macroengine:core/internal/api/store/_step_name [INTERNAL]
# The head follows an opening '%'. It is a token only when a closing '%' exists, i.e.
# another segment follows; otherwise "%" + head is kept as text.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set #st_mode macroengine.tmp 0
execute unless data storage macroengine:store tmp.segs[1] run data modify storage macroengine:store tmp.frags append value "%"
execute unless data storage macroengine:store tmp.segs[1] run return run function macroengine:core/internal/api/store/_step_text
function macroengine:core/internal/api/store/_resolve
data remove storage macroengine:store tmp.segs[0]
