# ======================================================================================
# macroengine:core/internal/ext/cooldown/arm [MACRO] [INTERNAL]
# Stores the new expiry (#ext_cd_new) for $(player)/$(key) and reports success.
# ======================================================================================

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$execute store result storage macroengine:engine cooldowns.$(player).$(key) int 1 run scoreboard players get #ext_cd_new macroengine.tmp
data modify storage macroengine:output result set value 1b
return 1
