# macroengine:core/internal/api/cmd/other/multi_cmd/cond_tag_object
# Object form. `has` defaults to 1b when omitted.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:engine _mcmd_cond_tmp set from storage macroengine:engine _mcmd_cond_eval.tag
execute unless data storage macroengine:engine _mcmd_cond_tmp.has run data modify storage macroengine:engine _mcmd_cond_tmp.has set value 1b
execute unless data storage macroengine:engine _mcmd_cond_tmp.name run function macroengine:core/internal/api/cmd/other/multi_cmd/cond_missing_key
function macroengine:core/internal/api/cmd/other/multi_cmd/cond_tag_obj_exec with storage macroengine:engine _mcmd_cond_tmp
data remove storage macroengine:engine _mcmd_cond_tmp
