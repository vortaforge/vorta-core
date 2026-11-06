# macroengine:core/internal/api/store/_p_get [MACRO] [INTERNAL]
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$execute unless data storage macroengine:store p."$(a)_$(b)_$(c)_$(d)".$(name) run return 0
$data modify storage macroengine:store out.value set from storage macroengine:store p."$(a)_$(b)_$(c)_$(d)".$(name)
return 1
