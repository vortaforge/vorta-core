execute if data storage vf_macro:string parts[0] unless data storage vf_macro:string parts[1] run data modify storage vf_macro:out Command set from storage vf_macro:string parts[0]
execute if data storage vf_macro:string parts[0] unless data storage vf_macro:string parts[1] run data modify storage vf_macro:in Command set from storage vf_macro:out Command
execute if data storage vf_macro:string parts[0] unless data storage vf_macro:string parts[1] run function vf_macro:api/macro/run

execute if data storage vf_macro:string parts[1] run tellraw @a [{"text":"[VF Macro] ","color":"red"},{"text":"ERROR: multiple tokens require multi_exec 1b (each token = one full command).","color":"white"}]
execute if data storage vf_macro:string parts[1] run schedule function vf_macro:core/cleanup 1t replace
