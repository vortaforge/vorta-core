# Convert in.replace_list → in.parts (pure)
# Each element:
#   {text:"..."}           → {text:"..."}
#   {key:"name"}           → {key:"name"}
#   {key:"name",value:"X"} → {text:"X"}  (pre-resolved)

execute if data storage vf_macro:internal free_list[0] run data modify storage vf_macro:internal current set from storage vf_macro:internal free_list[0]
execute if data storage vf_macro:internal free_list[0] run data remove storage vf_macro:internal free_list[0]

# text piece
execute if data storage vf_macro:internal current.text run data modify storage vf_macro:in parts append value {text:""}
execute if data storage vf_macro:internal current.text run data modify storage vf_macro:in parts[-1].text set from storage vf_macro:internal current.text

# pre-resolved value wins over key
execute unless data storage vf_macro:internal current.text if data storage vf_macro:internal current.value run data modify storage vf_macro:in parts append value {text:""}
execute unless data storage vf_macro:internal current.text if data storage vf_macro:internal current.value run data modify storage vf_macro:in parts[-1].text set from storage vf_macro:internal current.value

# key reference
execute unless data storage vf_macro:internal current.text unless data storage vf_macro:internal current.value if data storage vf_macro:internal current.key run data modify storage vf_macro:in parts append value {key:""}
execute unless data storage vf_macro:internal current.text unless data storage vf_macro:internal current.value if data storage vf_macro:internal current.key run data modify storage vf_macro:in parts[-1].key set from storage vf_macro:internal current.key

# clear current and recurse
data remove storage vf_macro:internal current
execute if data storage vf_macro:internal free_list[0] run function vf_macro:core/macro/replace_list_to_parts
