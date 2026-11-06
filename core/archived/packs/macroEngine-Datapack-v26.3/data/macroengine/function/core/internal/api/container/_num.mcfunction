# macroengine:core/internal/api/container/_num [INTERNAL, MACRO: f]
# Copies the NUMBER macroengine:input <f> into macroengine:container tmp.k.<f> as an int.
# <f> is always a constant written by this pack, never caller data. Caller data only ever
# travels as a number here, so it cannot carry command text into a macro line.
# RETURN 1 when <f> was a number, 0 otherwise (missing, string, list, compound).
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$execute store success score #ct_ok macroengine.tmp run data get storage macroengine:input $(f)
$execute if score #ct_ok macroengine.tmp matches 0 if data storage macroengine:input {$(f):0} run scoreboard players set #ct_ok macroengine.tmp 1
$execute if score #ct_ok macroengine.tmp matches 1 store result storage macroengine:container tmp.k.$(f) int 1 run data get storage macroengine:input $(f)
return run scoreboard players get #ct_ok macroengine.tmp
