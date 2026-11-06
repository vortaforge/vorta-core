# Queue all parts; step pops and runs one-by-one
data modify storage vf_macro:string exec_list set from storage vf_macro:string parts
function vf_macro:string/multi_exec_step
