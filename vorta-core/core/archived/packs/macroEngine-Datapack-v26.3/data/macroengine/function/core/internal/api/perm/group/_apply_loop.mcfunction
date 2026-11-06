# macroengine:core/internal/api/perm/group/_apply_loop [INTERNAL]
# Applies macroengine:engine _grp_tmp.pending (permission names) to the
# player whose pid is $grp_pid, adding or removing perm.<name> tags
# according to _grp_tmp.mode. Every name is checked with safe_name while
# still data, then handed to the macro one-liners - the same discipline as
# api/perm/require_eval.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:engine _grp_tmp.pending[0] run return 0
data remove storage macroengine:validate in
data modify storage macroengine:validate in.value set from storage macroengine:engine _grp_tmp.pending[0]
execute if function macroengine:systems/validate/safe_name if data storage macroengine:engine _grp_tmp{mode:"add"} run function macroengine:core/internal/api/perm/group/_add_one with storage macroengine:validate in
execute if data storage macroengine:validate out{valid:1b} if data storage macroengine:engine _grp_tmp{mode:"remove"} run function macroengine:core/internal/api/perm/group/_remove_one with storage macroengine:validate in
data remove storage macroengine:engine _grp_tmp.pending[0]
function macroengine:core/internal/api/perm/group/_apply_loop
