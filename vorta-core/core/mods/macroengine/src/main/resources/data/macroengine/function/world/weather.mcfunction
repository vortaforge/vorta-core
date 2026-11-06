# ======================================================================================
# macroengine:world/weather
# Reads the current weather at the executor's position, using the pack's own predicates.
#
# OUTPUT macroengine:output weather: "clear" | "rain" | "thunder"
# RETURN 0 = clear, 1 = rain, 2 = thunder
#
# Weather is per dimension on a server with several dimensions, so run it as/at the
# entity whose dimension you care about.
#
# Usage:
#   execute as @a[limit=1] at @s run function macroengine:world/weather
# ======================================================================================

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if predicate macroengine:is_thundering run data modify storage macroengine:output weather set value "thunder"
execute if predicate macroengine:is_thundering run return 2
execute if predicate macroengine:is_raining run data modify storage macroengine:output weather set value "rain"
execute if predicate macroengine:is_raining run return 1
data modify storage macroengine:output weather set value "clear"
return 0
