# vf_macro:string/set
# data modify storage vf_macro:string in.value set value "hello"
# function vf_macro:string/set
# → storage vf_macro:string out = "hello"
data modify storage vf_macro:string out set from storage vf_macro:string in.value
