# macroengine:core/internal/api/store/_p_default [MACRO] [INTERNAL]
$execute if data storage macroengine:store p."$(a)_$(b)_$(c)_$(d)".$(name) run return 0
$data modify storage macroengine:store p."$(a)_$(b)_$(c)_$(d)".$(name) set from storage macroengine:store in.value
return 1
