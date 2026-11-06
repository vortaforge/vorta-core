# macroengine:core/internal/api/store/_name [INTERNAL]
# Validates macroengine:store in.name and, when valid, copies it to tmp.k.name (the macro argument
# compound used by every _g_* / _p_* function). RETURN 1 valid, 0 invalid.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data remove storage macroengine:store tmp.k
data remove storage macroengine:validate in
data modify storage macroengine:validate in.value set from storage macroengine:store in.name
execute unless function macroengine:systems/validate/safe_name run return 0
data modify storage macroengine:store tmp.k.name set from storage macroengine:store in.name
return 1
