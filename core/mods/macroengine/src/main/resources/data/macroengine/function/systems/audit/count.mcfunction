# macroengine:systems/audit/count
# Number of stored audit entries (0..100).
# Output: macroengine:output result (int) and the function return value.
#
# Usage:  function macroengine:systems/audit/count

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{audit:0b} run return 0
execute store result score #macroengine.au_c macroengine.tmp run data get storage macroengine:audit entries
execute store result storage macroengine:output result int 1 run scoreboard players get #macroengine.au_c macroengine.tmp
return run scoreboard players get #macroengine.au_c macroengine.tmp
