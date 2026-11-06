# tokens / template + replace_list — see COMPAT.md

scoreboard objectives add vf_macro dummy
scoreboard players set #vf_macro.returned vf_macro 0
scoreboard players set #vf_macro.skip vf_macro 0
scoreboard players set #vf_macro.expanded vf_macro 0
scoreboard players set #vf_macro.key_found vf_macro 0
scoreboard players set #vf_macro.cmp vf_macro 0
scoreboard players set #vf_macro.multi vf_macro 0
scoreboard players set #vf_macro.force_ok vf_macro 0
scoreboard players set #vf_macro.resolve_done vf_macro 0

# --- tokens ---
execute if data storage vf_macro:in tokens[0] run data modify storage vf_macro:out resolved set value []
execute if data storage vf_macro:in tokens[0] run data modify storage vf_macro:internal token_list set from storage vf_macro:in tokens
execute if data storage vf_macro:in tokens[0] run function vf_macro:core/macro/resolve_tokens
execute if data storage vf_macro:in tokens[0] run function vf_macro:core/macro/join

# single token → run now; multi → force_join already scheduled steps (no cleanup here)
execute if data storage vf_macro:in tokens[0] if score #vf_macro.multi vf_macro matches 0 if data storage vf_macro:out Command run data modify storage vf_macro:in Command set from storage vf_macro:out Command
execute if data storage vf_macro:in tokens[0] if score #vf_macro.multi vf_macro matches 0 if data storage vf_macro:in Command run function vf_macro:api/macro/run
execute if data storage vf_macro:in tokens[0] if score #vf_macro.multi vf_macro matches 1 run scoreboard players set #vf_macro.skip vf_macro 1
execute if data storage vf_macro:in tokens[0] if score #vf_macro.multi vf_macro matches 0 run scoreboard players set #vf_macro.skip vf_macro 1

# --- string template ---
execute if score #vf_macro.skip vf_macro matches 0 unless data storage vf_macro:in template run tellraw @a [{"text":"[VF Macro] ","color":"red"},{"text":"ERROR: set template or tokens","color":"white"}]
execute if score #vf_macro.skip vf_macro matches 0 unless data storage vf_macro:in template run scoreboard players set #vf_macro.skip vf_macro 1

execute if score #vf_macro.skip vf_macro matches 0 run data modify storage vf_macro:internal cmd set from storage vf_macro:in template
execute if score #vf_macro.skip vf_macro matches 0 if data storage vf_macro:in replace_list[0] run data modify storage vf_macro:internal free_list set from storage vf_macro:in replace_list
execute if score #vf_macro.skip vf_macro matches 0 if data storage vf_macro:in replace_list[0] run function vf_macro:core/macro/apply_replace_list

execute if score #vf_macro.skip vf_macro matches 0 run data modify storage vf_macro:in Command set from storage vf_macro:internal cmd
execute if score #vf_macro.skip vf_macro matches 0 run function vf_macro:api/macro/run
