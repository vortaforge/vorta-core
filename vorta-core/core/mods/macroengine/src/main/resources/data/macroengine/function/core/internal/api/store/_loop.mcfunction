# macroengine:core/internal/api/store/_loop [INTERNAL]
# Walks tmp.segs, which alternate text, name, text, name ... (#st_mode 0 = text, 1 = name).
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:store tmp.segs[0] run return 0
execute if score #st_mode macroengine.tmp matches 0 run function macroengine:core/internal/api/store/_step_text
execute unless data storage macroengine:store tmp.segs[0] run return 0
execute if score #st_mode macroengine.tmp matches 1 run function macroengine:core/internal/api/store/_step_name
function macroengine:core/internal/api/store/_loop
