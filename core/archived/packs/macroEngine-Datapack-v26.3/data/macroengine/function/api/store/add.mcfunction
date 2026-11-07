# macroengine:api/store/add
# global value
#
# INPUT  macroengine:store in.name, in.by (int, default 1; negative subtracts)
# OUTPUT macroengine:store out.value = new value. Counters only: do not use on strings.
# RETURN 1 on success, 0 on invalid name / missing input / not a player.
#
# Plain strings in, plain strings out. Nothing here ever builds a text component.
# Names are checked with systems/validate/safe_name while they are still data in storage,
# before they reach a macro line (see api/perm/require for the same pattern).
execute if data storage macroengine:engine modules{store:0b} run return 0
data remove storage macroengine:store tmp
execute unless function macroengine:core/internal/api/store/_name run return 0
execute unless data storage macroengine:store in.by run data modify storage macroengine:store in.by set value 1
execute store result score #st_by macroengine.tmp run data get storage macroengine:store in.by
return run function macroengine:core/internal/api/store/_g_add with storage macroengine:store tmp.k
