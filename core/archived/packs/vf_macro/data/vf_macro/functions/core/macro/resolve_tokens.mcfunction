execute unless data storage vf_macro:internal token_list[0] run scoreboard players set #vf_macro.resolve_done vf_macro 1

execute if data storage vf_macro:internal token_list[0] run data modify storage vf_macro:internal current set from storage vf_macro:internal token_list[0]
execute if data storage vf_macro:internal token_list[0] run data remove storage vf_macro:internal token_list[0]

# literal text / value
execute if data storage vf_macro:internal current.value run data modify storage vf_macro:out resolved append from storage vf_macro:internal current.value
execute unless data storage vf_macro:internal current.value if data storage vf_macro:internal current.text run data modify storage vf_macro:out resolved append from storage vf_macro:internal current.text

# key → search replace_list (and a copy of args as list? only replace_list — no hardcoded names)
execute if data storage vf_macro:internal current.key run scoreboard players set #vf_macro.key_found vf_macro 0
execute if data storage vf_macro:internal current.key run data modify storage vf_macro:internal want_key set from storage vf_macro:internal current.key
execute if data storage vf_macro:internal current.key run data modify storage vf_macro:internal scan_list set from storage vf_macro:in replace_list
execute if data storage vf_macro:internal current.key run function vf_macro:core/macro/match_key_in_list
execute if data storage vf_macro:internal current.key if score #vf_macro.key_found vf_macro matches 1 run data modify storage vf_macro:out resolved append from storage vf_macro:internal matched_value
execute if data storage vf_macro:internal current.key if score #vf_macro.key_found vf_macro matches 0 run data modify storage vf_macro:out resolved append value "$(?)"

execute if data storage vf_macro:internal token_list[0] run function vf_macro:core/macro/resolve_tokens
