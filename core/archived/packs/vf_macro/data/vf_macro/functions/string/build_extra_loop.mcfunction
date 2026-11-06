execute unless data storage vf_macro:string build_list[0] run scoreboard players set #vf_macro.resolve_done vf_macro 1

execute if data storage vf_macro:string build_list[0] run data modify storage vf_macro:string tmp set value {text:""}
execute if data storage vf_macro:string build_list[0] run data modify storage vf_macro:string tmp.text set from storage vf_macro:string build_list[0]
execute if data storage vf_macro:string build_list[0] run data modify storage vf_macro:string extra append from storage vf_macro:string tmp
execute if data storage vf_macro:string build_list[0] run data remove storage vf_macro:string build_list[0]

execute if data storage vf_macro:string build_list[0] run function vf_macro:string/build_extra_loop
