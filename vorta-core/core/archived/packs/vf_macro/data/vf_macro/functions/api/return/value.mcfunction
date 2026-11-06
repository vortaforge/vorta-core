# PUBLIC API — vf_macro:api/return/value
# Simulates /return <value>
# Caller should set storage vf_macro:in value first, or use the score form.

# Prefer explicit storage value
execute if data storage vf_macro:in value run data modify storage vf_macro:out return_value set from storage vf_macro:in value
execute if data storage vf_macro:in value run scoreboard players set #vf_macro.returned vf_macro 1
execute if data storage vf_macro:in value run data modify storage vf_macro:out return_success set value 1b

# Fallback: use score #vf_macro.return_value if present
execute unless data storage vf_macro:in value if score #vf_macro.return_value vf_macro = #vf_macro.return_value vf_macro run execute store result storage vf_macro:out return_value int 1 run scoreboard players get #vf_macro.return_value vf_macro
execute unless data storage vf_macro:in value if score #vf_macro.return_value vf_macro = #vf_macro.return_value vf_macro run scoreboard players set #vf_macro.returned vf_macro 1
execute unless data storage vf_macro:in value if score #vf_macro.return_value vf_macro = #vf_macro.return_value vf_macro run data modify storage vf_macro:out return_success set value 1b
