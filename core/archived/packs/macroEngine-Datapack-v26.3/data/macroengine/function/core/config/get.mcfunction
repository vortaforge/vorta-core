# macroengine:core/config/get
# Reads one runtime config value.
# INPUT  macroengine:engine config_in.key   any key from docs/config.md
# OUTPUT macroengine:output result          the value (removed first, so a stale value never survives a miss)
# RETURN 1 when the key exists, 0 otherwise.
data remove storage macroengine:output result
execute unless data storage macroengine:engine config_in.key run return 0
data remove storage macroengine:validate in
data modify storage macroengine:validate in.value set from storage macroengine:engine config_in.key
execute unless function macroengine:systems/validate/safe_name run return 0
data modify storage macroengine:engine config_k set value {}
data modify storage macroengine:engine config_k.key set from storage macroengine:engine config_in.key
function macroengine:core/config/_get_exec with storage macroengine:engine config_k
execute if data storage macroengine:output result run return 1
return 0
