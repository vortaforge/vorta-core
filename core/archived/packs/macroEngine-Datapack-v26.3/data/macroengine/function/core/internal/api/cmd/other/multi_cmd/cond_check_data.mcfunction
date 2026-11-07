# ─────────────────────────────────────────────────────────────────
# macroengine:core/internal/api/cmd/other/multi_cmd/cond_check_data
# Numeric storage leaf.
#   condition.data = {storage:"namespace:path", path:"a.b", min:1, max:10}
#
# Keys:
#   storage  required — the storage namespace, e.g. "macroengine:engine"
#   path     required — NBT path inside it, e.g. "state.counter"
#   min      -2147483648  lower bound, inclusive
#   max       2147483647  upper bound, inclusive
#   scale     1           multiplier applied by `data get ... scale`
#
# Equality on an integer is min == max. A missing path fails closed, which
# is what makes this safer than the existence-only `storage` leaf.
#
# LIMITATION: only numeric values can be compared. Minecraft has no
# command that tests two NBT values for equality, so string/compound
# comparison is deliberately not offered here rather than faked.
# ─────────────────────────────────────────────────────────────────

data modify storage macroengine:engine _mcmd_cond_tmp set from storage macroengine:engine _mcmd_cond_eval.data

execute unless data storage macroengine:engine _mcmd_cond_tmp.min run data modify storage macroengine:engine _mcmd_cond_tmp.min set value -2147483648
execute unless data storage macroengine:engine _mcmd_cond_tmp.max run data modify storage macroengine:engine _mcmd_cond_tmp.max set value 2147483647
execute unless data storage macroengine:engine _mcmd_cond_tmp.scale run data modify storage macroengine:engine _mcmd_cond_tmp.scale set value 1

execute unless data storage macroengine:engine _mcmd_cond_tmp.storage run function macroengine:core/internal/api/cmd/other/multi_cmd/cond_missing_key
execute unless data storage macroengine:engine _mcmd_cond_tmp.path run function macroengine:core/internal/api/cmd/other/multi_cmd/cond_missing_key

execute if data storage macroengine:engine _mcmd_cond_tmp.storage if data storage macroengine:engine _mcmd_cond_tmp.path run function macroengine:core/internal/api/cmd/other/multi_cmd/cond_data_exec with storage macroengine:engine _mcmd_cond_tmp

data remove storage macroengine:engine _mcmd_cond_tmp
