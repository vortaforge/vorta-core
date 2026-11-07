# macroengine:api/store/text/remove
# Removes one language of a template. INPUT macroengine:store in.name, in.lang. RETURN 1 / 0.
execute if data storage macroengine:engine modules{store:0b} run return 0
data remove storage macroengine:store tmp
execute unless function macroengine:core/internal/api/store/_name run return 0
execute unless function macroengine:core/internal/api/store/_lang run return 0
return run function macroengine:core/internal/api/store/_t_remove with storage macroengine:store tmp.k
