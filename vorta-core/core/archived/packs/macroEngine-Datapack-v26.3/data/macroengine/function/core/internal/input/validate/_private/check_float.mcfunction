# ======================================================================================
# macroengine:core/internal/input/validate/_private/check_float  [INTERNAL]
# ======================================================================================
# A whole number or a decimal: optional leading '-', digits, and at most one '.' that has
# digits on both sides ("1." and ".5" are rejected as ambiguous rather than guessed at).
# Delegates to macroengine:core/internal/text/num_check with allow_dot set.
# ======================================================================================
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:text s set from storage macroengine:input_validate scratch.value
data modify storage macroengine:text allow_dot set value 1b
execute store result score #macroengine.NumOk macroengine.tmp run function macroengine:core/internal/text/num_check
execute if score #macroengine.NumOk macroengine.tmp matches 1 run data modify storage macroengine:input_validate result.valid set value 1b
execute unless score #macroengine.NumOk macroengine.tmp matches 1 run data modify storage macroengine:input_validate result.error set from storage macroengine:text err
data remove storage macroengine:text allow_dot
function macroengine:core/internal/text/reset
