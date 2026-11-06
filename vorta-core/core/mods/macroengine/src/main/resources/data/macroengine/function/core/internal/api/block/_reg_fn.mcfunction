# macroengine:core/internal/api/block/_reg_fn [INTERNAL, MACRO: k]
# Register step for one handler key: absent is fine, present must be a valid function id.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$execute unless data storage macroengine:input $(k) run return 1
data remove storage macroengine:validate in
$data modify storage macroengine:validate in.value set from storage macroengine:input $(k)
execute unless function macroengine:systems/validate/function_id run return 0
$data modify storage macroengine:block tmp.reg.$(k) set from storage macroengine:input $(k)
return 1
