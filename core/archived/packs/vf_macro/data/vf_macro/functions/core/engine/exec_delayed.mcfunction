# Runs 1t after setup — chunk should be forced by then
data modify storage vf_macro:engine Command set from storage vf_macro:engine pending
function vf_macro:core/engine/exec
