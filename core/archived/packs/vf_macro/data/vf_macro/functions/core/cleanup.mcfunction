data remove storage vf_macro:internal current
data remove storage vf_macro:internal resolve_list
data remove storage vf_macro:internal token_list
data remove storage vf_macro:internal cmd
data remove storage vf_macro:internal free_list
data remove storage vf_macro:internal free_item
data remove storage vf_macro:internal scan_list
data remove storage vf_macro:internal scan_item
data remove storage vf_macro:internal want_key
data remove storage vf_macro:internal matched_value
data remove storage vf_macro:in template
data remove storage vf_macro:in tokens
data remove storage vf_macro:in replace_list
data remove storage vf_macro:in source
data remove storage vf_macro:in parts
data remove storage vf_macro:in Command
data remove storage vf_macro:in value
data remove storage vf_macro:in data
data remove storage vf_macro:engine Command
data remove storage vf_macro:engine pending
data remove storage vf_macro:out Command
data remove storage vf_macro:out resolved
data remove storage vf_macro:out sign_payload
data remove storage vf_macro:string parts
data remove storage vf_macro:string exec_list
data remove storage vf_macro:string extra
data remove storage vf_macro:string build_list
data remove storage vf_macro:string tmp
data remove storage vf_macro:string in
data remove storage vf_macro:string out
data remove storage vf_macro:string sign_payload
data remove storage vf_macro:string joined_json

scoreboard players set #vf_macro.skip vf_macro 0
scoreboard players set #vf_macro.multi vf_macro 0
scoreboard players set #vf_macro.resolve_done vf_macro 0
scoreboard players set #vf_macro.expanded vf_macro 0
scoreboard players set #vf_macro.free_done vf_macro 0
scoreboard players set #vf_macro.cmp vf_macro 0
scoreboard players set #vf_macro.key_found vf_macro 0
scoreboard players set #vf_macro.force_ok vf_macro 0
