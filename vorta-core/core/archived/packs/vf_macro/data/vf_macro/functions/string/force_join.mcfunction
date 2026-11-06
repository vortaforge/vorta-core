scoreboard players set #vf_macro.force_ok vf_macro 0

# multi_exec enabled?
execute if data storage vf_macro:config {multi_exec:1b} run scoreboard players set #vf_macro.force_ok vf_macro 1
execute if data storage vf_macro:config {multi_exec:1} run scoreboard players set #vf_macro.force_ok vf_macro 1

execute if score #vf_macro.force_ok vf_macro matches 1 run function vf_macro:string/multi_exec

# Fallback message (English only)
execute if score #vf_macro.force_ok vf_macro matches 0 run tellraw @a [{"text":"[VF Macro] ","color":"red"},{"text":"ERROR: multiple tokens need config multi_exec 1b (each token = full command), or pass a single full Command.","color":"white"}]
execute if score #vf_macro.force_ok vf_macro matches 0 run schedule function vf_macro:core/cleanup 1t replace
