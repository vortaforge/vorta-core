# macroengine:core/internal/api/store/_tok_ent [INTERNAL]  tokens %health% %food% %xp_level% %dimension%
# Reads the executor's data directly and stores a plain string in tmp.val (unset for non-players).
execute unless entity @s[type=player] run return 0
data remove storage macroengine:store tmp.num
execute if data storage macroengine:store tmp{nm:"health"} store result storage macroengine:store tmp.num int 1 run data get entity @s Health
execute if data storage macroengine:store tmp{nm:"food"} store result storage macroengine:store tmp.num int 1 run data get entity @s foodLevel
execute if data storage macroengine:store tmp{nm:"xp_level"} store result storage macroengine:store tmp.num int 1 run data get entity @s XpLevel
execute if data storage macroengine:store tmp.num run data modify storage macroengine:store tmp.val set string storage macroengine:store tmp.num
execute if data storage macroengine:store tmp{nm:"dimension"} run data modify storage macroengine:store tmp.val set string entity @s Dimension
data remove storage macroengine:store tmp.num
