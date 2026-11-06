# replace_list entry: {find:"$(x)", value:"..." }
# value may be empty string "" — still updates cmd
# Full-string equality only

execute unless data storage vf_macro:internal free_list[0] run scoreboard players set #vf_macro.free_done vf_macro 1

execute if data storage vf_macro:internal free_list[0] run data modify storage vf_macro:internal free_item set from storage vf_macro:internal free_list[0]
execute if data storage vf_macro:internal free_list[0] run data remove storage vf_macro:internal free_list[0]

# Compare cmd to find
execute if data storage vf_macro:internal free_item.find run data modify storage vf_macro:string tmp.check set from storage vf_macro:internal cmd
execute if data storage vf_macro:internal free_item.find run execute store success score #vf_macro.cmp vf_macro run data modify storage vf_macro:string tmp.check set from storage vf_macro:internal free_item.find

# On match: always write value (even "" ). Missing value → skip write.
execute if data storage vf_macro:internal free_item.find if score #vf_macro.cmp vf_macro matches 0 run data modify storage vf_macro:internal has_val set value 0b
execute if data storage vf_macro:internal free_item.find if score #vf_macro.cmp vf_macro matches 0 if data storage vf_macro:internal free_item.value run data modify storage vf_macro:internal has_val set value 1b
# Empty string: path "value" exists with "". if data is true. Good.
# Use set from unconditionally when find matched AND value key exists (including "")
execute if data storage vf_macro:internal free_item.find if score #vf_macro.cmp vf_macro matches 0 if data storage vf_macro:internal free_item.value run data modify storage vf_macro:internal cmd set from storage vf_macro:internal free_item.value
execute if data storage vf_macro:internal free_item.find if score #vf_macro.cmp vf_macro matches 0 if data storage vf_macro:internal free_item.value run scoreboard players set #vf_macro.expanded vf_macro 1

# Allow explicit empty via value set to "" — if data on empty string is true in MC.
# Also allow {find:"$(x)", value:""} 

execute if data storage vf_macro:internal free_list[0] run function vf_macro:core/macro/apply_replace_list
