# Start with single segment = full template
data modify storage vf_macro:out resolved set value []
data modify storage vf_macro:out resolved append from storage vf_macro:internal cmd

# No keys → done (literal template)
execute unless data storage vf_macro:internal present_keys[0] run data modify storage vf_macro:out note set value "no placeholders"

# For each key, split all segments on that token
data modify storage vf_macro:internal expand_keys set from storage vf_macro:internal present_keys
execute if data storage vf_macro:internal expand_keys[0] run function vf_macro:core/macro/expand_key_loop
