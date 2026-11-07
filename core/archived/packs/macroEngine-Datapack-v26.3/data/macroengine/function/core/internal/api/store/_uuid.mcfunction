# macroengine:core/internal/api/store/_uuid [INTERNAL]
# Splits the executor's UUID into four ints in tmp.k (a, b, c, d). Ints cannot carry
# command text, so they are safe macro arguments. RETURN 1 for a player, else 0.
execute unless entity @s[type=player] run return 0
data modify storage macroengine:store tmp.uuid set from entity @s UUID
data modify storage macroengine:store tmp.k.a set from storage macroengine:store tmp.uuid[0]
data modify storage macroengine:store tmp.k.b set from storage macroengine:store tmp.uuid[1]
data modify storage macroengine:store tmp.k.c set from storage macroengine:store tmp.uuid[2]
data modify storage macroengine:store tmp.k.d set from storage macroengine:store tmp.uuid[3]
return 1
