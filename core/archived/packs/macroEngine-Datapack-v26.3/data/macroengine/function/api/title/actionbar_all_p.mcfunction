# macroengine:api/title/actionbar_all_p
# actionbar_p for every online player. Storage input as actionbar_p.
execute if data storage macroengine:engine modules{title:0b} run return 0
execute as @a run function macroengine:api/title/actionbar_p
