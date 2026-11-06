# macroengine:core/internal/api/gamerule/debug_print [MACRO]
# Internal — do not call directly.
#
# Emits the gamerule/get debug line. Split out from api/gamerule/get so the
# $(_gamerule_norm) macro arg is bound fresh from storage AFTER the normalize
# step writes it, instead of at get.mcfunction's own entry (before the value
# existed).
#
# Expects: {_gamerule_norm:"..."}

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"gamerule/get ","color":"aqua"},{"text":" → ","color":"#555555"},{"text":"$(_gamerule_norm)","color":"white"},{"text":" = ","color":"#555555"},{"plain":true ,"storage":"macroengine:output","nbt":"gamerule","color":"green","interpret":false}]
