# Sequential engine pulses — does NOT call api/macro/run (that cleanup would wipe exec_list)

execute unless data storage vf_macro:string exec_list[0] run function vf_macro:core/cleanup
execute unless data storage vf_macro:string exec_list[0] run scoreboard players set #vf_macro.force_ok vf_macro 1

# Pop one command into engine (keep exec_list intact until after copy)
execute if data storage vf_macro:string exec_list[0] run data modify storage vf_macro:engine Command set from storage vf_macro:string exec_list[0]
execute if data storage vf_macro:string exec_list[0] run data modify storage vf_macro:out Command set from storage vf_macro:string exec_list[0]
execute if data storage vf_macro:string exec_list[0] run data remove storage vf_macro:string exec_list[0]

# Pulse engine without going through api/macro/run cleanup
execute if data storage vf_macro:engine Command run scoreboard players set #vf_macro.skip vf_macro 0
execute if data storage vf_macro:engine Command run function vf_macro:core/engine/run

# More remaining → schedule next (after engine delay ~1+4t)
execute if data storage vf_macro:string exec_list[0] run schedule function vf_macro:string/multi_exec_step 6t replace
# None left → final cleanup on next pass (unless branch at top) — schedule one more tick to cleanup after last pulse
execute unless data storage vf_macro:string exec_list[0] if data storage vf_macro:engine Command run schedule function vf_macro:string/multi_exec_done 6t replace
