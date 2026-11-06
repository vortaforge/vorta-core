# Items: {text:"..."} or {value:"..."}. No key whitelist. Recursive.
execute unless data storage vf_macro:internal resolve_list[0] run scoreboard players set #vf_macro.resolve_done vf_macro 1

execute if data storage vf_macro:internal resolve_list[0] run data modify storage vf_macro:internal current set from storage vf_macro:internal resolve_list[0]
execute if data storage vf_macro:internal resolve_list[0] run data remove storage vf_macro:internal resolve_list[0]

execute if data storage vf_macro:internal current.value run data modify storage vf_macro:out resolved append from storage vf_macro:internal current.value
execute unless data storage vf_macro:internal current.value if data storage vf_macro:internal current.text run data modify storage vf_macro:out resolved append from storage vf_macro:internal current.text

execute if data storage vf_macro:internal resolve_list[0] run function vf_macro:core/macro/resolve_parts
