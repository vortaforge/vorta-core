# macroengine:api/store/render_all
# Renders the same template once for every online player (each render runs as that player, so
# %player%, %p:name% and %score:obj% resolve per recipient) and collects plain strings.
#
# INPUT  same as api/store/render (in.template or in.name, in.lang, in.args)
# OUTPUT macroengine:store all.entries  list of {uuid:[I;...],string:"..."}, one per player whose
#                                       render succeeded
# RETURN number of entries
#
# Usage:
#   data modify storage macroengine:store in set value {template:"Hi %player%, coins: %score:coins%"}
#   function macroengine:api/store/render_all
execute if data storage macroengine:engine modules{store:0b} run return 0
data remove storage macroengine:store all
data modify storage macroengine:store all.entries set value []
execute as @a run function macroengine:core/internal/api/store/_all_one
return run data get storage macroengine:store all.entries
