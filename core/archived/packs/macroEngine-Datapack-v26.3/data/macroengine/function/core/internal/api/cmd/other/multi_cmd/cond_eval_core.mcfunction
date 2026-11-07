# ─────────────────────────────────────────────────────────────────
# macroengine:core/internal/api/cmd/other/multi_cmd/cond_eval_core
# Evaluates ONE condition object and writes the verdict to
# $mcmd_cond_result macroengine.tmp (1 = passed, 0 = not passed).
#
# INPUT (storage macroengine:engine _mcmd_cond_eval): the condition object.
#
# Leaf keys are AND-combined:
#   tag        "name" | {name:"...", has:1b|0b}
#   score      {objective:"...", min:.., max:.., target:"@s"}   (target/bounds optional)
#   predicate  "namespace:path"
#   entity     "<selector>"
#   storage    "namespace:path"          (existence only, kept for compatibility)
#   data       {storage:"...", path:"...", min:.., max:.., scale:..}  (numeric range)
#
# Composition keys, usable alongside the leaves and nestable:
#   all_of     [ {..}, {..} ]   every child must pass  (AND)
#   any_of     [ {..}, {..} ]   at least one must pass (OR)
#   not        {..}             inverts the child
#
# NOTE: _mcmd_cond_eval is treated as scratch — this function and the
# composition helpers overwrite it. Callers that still need the object
# afterwards must copy it out first.
# ─────────────────────────────────────────────────────────────────

# Default verdict: passed. Each leaf below can only clear it.
scoreboard players set $mcmd_cond_result macroengine.tmp 1

execute if data storage macroengine:engine _mcmd_cond_eval.tag run function macroengine:core/internal/api/cmd/other/multi_cmd/cond_check_tag
execute if data storage macroengine:engine _mcmd_cond_eval.score run function macroengine:core/internal/api/cmd/other/multi_cmd/cond_check_score
execute if data storage macroengine:engine _mcmd_cond_eval.predicate run function macroengine:core/internal/api/cmd/other/multi_cmd/cond_check_predicate
execute if data storage macroengine:engine _mcmd_cond_eval.entity run function macroengine:core/internal/api/cmd/other/multi_cmd/cond_check_entity
execute if data storage macroengine:engine _mcmd_cond_eval.storage run function macroengine:core/internal/api/cmd/other/multi_cmd/cond_check_storage
execute if data storage macroengine:engine _mcmd_cond_eval.data run function macroengine:core/internal/api/cmd/other/multi_cmd/cond_check_data

# Composition. Guarded by the running verdict so a failing leaf
# short-circuits the (potentially expensive) tree walks.
execute if score $mcmd_cond_result macroengine.tmp matches 1 if data storage macroengine:engine _mcmd_cond_eval.all_of run function macroengine:core/internal/api/cmd/other/multi_cmd/cond_all_of
execute if score $mcmd_cond_result macroengine.tmp matches 1 if data storage macroengine:engine _mcmd_cond_eval.any_of run function macroengine:core/internal/api/cmd/other/multi_cmd/cond_any_of
execute if score $mcmd_cond_result macroengine.tmp matches 1 if data storage macroengine:engine _mcmd_cond_eval.not run function macroengine:core/internal/api/cmd/other/multi_cmd/cond_not
