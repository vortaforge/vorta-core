# macroengine:core/internal/api/cmd/other/multi_cmd/cond_tag_object
# Object form. `has` defaults to 1b when omitted.

data modify storage macroengine:engine _mcmd_cond_tmp set from storage macroengine:engine _mcmd_cond_eval.tag
execute unless data storage macroengine:engine _mcmd_cond_tmp.has run data modify storage macroengine:engine _mcmd_cond_tmp.has set value 1b
execute unless data storage macroengine:engine _mcmd_cond_tmp.name run function macroengine:core/internal/api/cmd/other/multi_cmd/cond_missing_key
function macroengine:core/internal/api/cmd/other/multi_cmd/cond_tag_obj_exec with storage macroengine:engine _mcmd_cond_tmp
data remove storage macroengine:engine _mcmd_cond_tmp
