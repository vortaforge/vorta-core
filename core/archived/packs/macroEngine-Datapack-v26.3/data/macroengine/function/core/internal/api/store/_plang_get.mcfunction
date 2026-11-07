# macroengine:core/internal/api/store/_plang_get [MACRO] [INTERNAL]
$execute if data storage macroengine:store p."$(a)_$(b)_$(c)_$(d)".lang run data modify storage macroengine:store tmp.langs append from storage macroengine:store p."$(a)_$(b)_$(c)_$(d)".lang
