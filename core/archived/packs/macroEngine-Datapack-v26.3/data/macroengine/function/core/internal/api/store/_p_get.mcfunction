# macroengine:core/internal/api/store/_p_get [MACRO] [INTERNAL]
$execute unless data storage macroengine:store p."$(a)_$(b)_$(c)_$(d)".$(name) run return 0
$data modify storage macroengine:store out.value set from storage macroengine:store p."$(a)_$(b)_$(c)_$(d)".$(name)
return 1
