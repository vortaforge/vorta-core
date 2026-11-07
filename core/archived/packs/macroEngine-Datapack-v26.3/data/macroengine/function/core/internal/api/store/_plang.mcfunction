# macroengine:core/internal/api/store/_plang [INTERNAL]
# Appends the executor's own "lang" value (api/store/player/set) to tmp.langs.
data modify storage macroengine:store tmp.pk set value {}
data modify storage macroengine:store tmp.uuid set from entity @s UUID
data modify storage macroengine:store tmp.pk.a set from storage macroengine:store tmp.uuid[0]
data modify storage macroengine:store tmp.pk.b set from storage macroengine:store tmp.uuid[1]
data modify storage macroengine:store tmp.pk.c set from storage macroengine:store tmp.uuid[2]
data modify storage macroengine:store tmp.pk.d set from storage macroengine:store tmp.uuid[3]
function macroengine:core/internal/api/store/_plang_get with storage macroengine:store tmp.pk
