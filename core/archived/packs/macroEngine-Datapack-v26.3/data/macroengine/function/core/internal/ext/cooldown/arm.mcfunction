# ======================================================================================
# macroengine:core/internal/ext/cooldown/arm [MACRO] [INTERNAL]
# Stores the new expiry (#ext_cd_new) for $(player)/$(key) and reports success.
# ======================================================================================

$execute store result storage macroengine:engine cooldowns.$(player).$(key) int 1 run scoreboard players get #ext_cd_new macroengine.tmp
data modify storage macroengine:output result set value 1b
return 1
