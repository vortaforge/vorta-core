# parts[] strings → extra [{text:s}, ...]
data modify storage vf_macro:string extra set value []
data modify storage vf_macro:string build_list set from storage vf_macro:string parts
function vf_macro:string/build_extra_loop
