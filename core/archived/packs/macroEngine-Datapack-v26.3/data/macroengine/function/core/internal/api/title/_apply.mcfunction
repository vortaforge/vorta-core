# macroengine:core/internal/api/title/_apply [MACRO, INTERNAL]
# $(fade_in) $(stay) $(fade_out) are numbers copied from storage by show_p.
# macroengine:title t and s are plain strings; interpret=false prints them as written.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$title @s times $(fade_in) $(stay) $(fade_out)
title @s subtitle {"storage":"macroengine:title","nbt":"s","interpret":false,"plain":true}
title @s title {"storage":"macroengine:title","nbt":"t","interpret":false,"plain":true}
