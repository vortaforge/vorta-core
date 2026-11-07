# macroengine:core/internal/api/store/_p_add [MACRO] [INTERNAL]
# #st_by holds the amount; a missing value counts as 0.
scoreboard players set #st_v macroengine.tmp 0
$execute store result score #st_v macroengine.tmp run data get storage macroengine:store p."$(a)_$(b)_$(c)_$(d)".$(name)
scoreboard players operation #st_v macroengine.tmp += #st_by macroengine.tmp
$execute store result storage macroengine:store p."$(a)_$(b)_$(c)_$(d)".$(name) int 1 run scoreboard players get #st_v macroengine.tmp
execute store result storage macroengine:store out.value int 1 run scoreboard players get #st_v macroengine.tmp
return run scoreboard players get #st_v macroengine.tmp
