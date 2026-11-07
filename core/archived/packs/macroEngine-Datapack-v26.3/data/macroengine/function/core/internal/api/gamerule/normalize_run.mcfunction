# macroengine:core/internal/api/gamerule/normalize_run  [INTERNAL]
# Called by normalize, which resets the text buffers afterwards.
data modify storage macroengine:text s set from storage macroengine:input rule
data modify storage macroengine:text needle set value " "
data modify storage macroengine:text rep set value "_"
data modify storage macroengine:text n set value 0
function macroengine:core/internal/text/replace
execute if data storage macroengine:text err run return fail
data modify storage macroengine:text s set from storage macroengine:text out
function macroengine:core/internal/text/lower
execute if data storage macroengine:text err run return fail
data modify storage macroengine:input _gamerule_norm set from storage macroengine:text out
