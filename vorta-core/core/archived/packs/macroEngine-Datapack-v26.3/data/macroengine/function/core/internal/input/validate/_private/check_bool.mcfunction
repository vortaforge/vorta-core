# ======================================================================================
# macroengine:core/internal/input/validate/_private/check_bool  [INTERNAL]
# ======================================================================================
# Requires scratch.value to be the exact string "true" or "false". No
# case-folding — "True"/"TRUE" are rejected on purpose, since silently
# accepting them just moves the ambiguity one step further down instead
# of resolving it.
# ======================================================================================

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:input_validate {scratch:{value:"true"}} run data modify storage macroengine:input_validate result.valid set value 1b
execute if data storage macroengine:input_validate {scratch:{value:"false"}} run data modify storage macroengine:input_validate result.valid set value 1b

execute unless data storage macroengine:input_validate {result:{valid:1b}} run data modify storage macroengine:input_validate result.error set value "expected exactly \"true\" or \"false\""
