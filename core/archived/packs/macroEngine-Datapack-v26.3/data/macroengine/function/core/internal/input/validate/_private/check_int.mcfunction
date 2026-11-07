# ======================================================================================
# macroengine:core/internal/input/validate/_private/check_int  [INTERNAL]
# ======================================================================================
# A whole number: optional leading '-', then one or more digits. Delegates to
# macroengine:core/internal/text/num_check, which walks the string one character at a
# time and never substitutes the input into a command line.
# ======================================================================================
data modify storage macroengine:text s set from storage macroengine:input_validate scratch.value
data modify storage macroengine:text allow_dot set value 0b
execute store result score #macroengine.NumOk macroengine.tmp run function macroengine:core/internal/text/num_check
execute if score #macroengine.NumOk macroengine.tmp matches 1 run data modify storage macroengine:input_validate result.valid set value 1b
execute unless score #macroengine.NumOk macroengine.tmp matches 1 run data modify storage macroengine:input_validate result.error set from storage macroengine:text err
data remove storage macroengine:text allow_dot
function macroengine:core/internal/text/reset
