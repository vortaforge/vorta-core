# Private — expand placeholders in template
#
# Priority:
#   1. vf_macro:in replace_list  → free placeholders [{key, value}, ...]
#   2. vf_macro:args + whitelist → convenience keys

data modify storage vf_macro:internal cmd set from storage vf_macro:in template
data modify storage vf_macro:internal present_keys set value []
scoreboard players set #vf_macro.free_done vf_macro 0

# --- Free placeholders ---
execute if data storage vf_macro:in replace_list[0] run data modify storage vf_macro:internal free_list set from storage vf_macro:in replace_list
execute if data storage vf_macro:in replace_list[0] run function vf_macro:core/macro/replace_free
execute if data storage vf_macro:in replace_list[0] run data modify storage vf_macro:out note set value "expanded via free replace_list"

# --- Whitelist from args (always applied after, so both can be used) ---
execute if data storage vf_macro:args name run data modify storage vf_macro:internal present_keys append value "name"
execute if data storage vf_macro:args amount run data modify storage vf_macro:internal present_keys append value "amount"
execute if data storage vf_macro:args value run data modify storage vf_macro:internal present_keys append value "value"
execute if data storage vf_macro:args player run data modify storage vf_macro:internal present_keys append value "player"
execute if data storage vf_macro:args id run data modify storage vf_macro:internal present_keys append value "id"
execute if data storage vf_macro:args x run data modify storage vf_macro:internal present_keys append value "x"
execute if data storage vf_macro:args y run data modify storage vf_macro:internal present_keys append value "y"
execute if data storage vf_macro:args z run data modify storage vf_macro:internal present_keys append value "z"
execute if data storage vf_macro:args pos run data modify storage vf_macro:internal present_keys append value "pos"
execute if data storage vf_macro:args cmd run data modify storage vf_macro:internal present_keys append value "cmd"
execute if data storage vf_macro:args func run data modify storage vf_macro:internal present_keys append value "func"
execute if data storage vf_macro:args msg run data modify storage vf_macro:internal present_keys append value "msg"
execute if data storage vf_macro:args text run data modify storage vf_macro:internal present_keys append value "text"
execute if data storage vf_macro:args count run data modify storage vf_macro:internal present_keys append value "count"
execute if data storage vf_macro:args score run data modify storage vf_macro:internal present_keys append value "score"
execute if data storage vf_macro:args target run data modify storage vf_macro:internal present_keys append value "target"
execute if data storage vf_macro:args selector run data modify storage vf_macro:internal present_keys append value "selector"
execute if data storage vf_macro:args path run data modify storage vf_macro:internal present_keys append value "path"
execute if data storage vf_macro:args storage run data modify storage vf_macro:internal present_keys append value "storage"
execute if data storage vf_macro:args key run data modify storage vf_macro:internal present_keys append value "key"

data modify storage vf_macro:out present_keys set from storage vf_macro:internal present_keys
execute if data storage vf_macro:internal present_keys[0] run function vf_macro:core/macro/replace_keys
