# vf_macro:string/replace
# 1.16–1.19.3 cannot do arbitrary substring replace (no set string).
# This function only handles the full-string case; partial replace is done
# by core/macro/expand_tokens via resolved-list join (same visual result as parts).
data modify storage vf_macro:string out set from storage vf_macro:string in.string
data modify storage vf_macro:string tmp.check set from storage vf_macro:string in.string
execute store success score #vf_macro.cmp vf_macro run data modify storage vf_macro:string tmp.check set from storage vf_macro:string in.old
execute if score #vf_macro.cmp vf_macro matches 0 run data modify storage vf_macro:string out set from storage vf_macro:string in.new
