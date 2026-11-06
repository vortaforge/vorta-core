# ======================================================================================
# macroengine:core/internal/ext/input/int_to_score [MACRO] [INTERNAL]
# $(s) is a string that already passed input/validate/check (optional '-', digits only)
# and is at most 9 characters long, so the score command cannot fail or overflow.
# ======================================================================================

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$scoreboard players set #ext_ir_val macroengine.tmp $(s)
