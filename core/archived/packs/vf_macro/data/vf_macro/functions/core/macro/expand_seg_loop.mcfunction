data modify storage vf_macro:internal seg set from storage vf_macro:internal seg_work[0]
data remove storage vf_macro:internal seg_work[0]

scoreboard players set #vf_macro.seg_done vf_macro 0

# 1) Exact token match
data modify storage vf_macro:string tmp.check set from storage vf_macro:internal seg
execute store success score #vf_macro.cmp vf_macro run data modify storage vf_macro:string tmp.check set from storage vf_macro:internal find
execute if score #vf_macro.cmp vf_macro matches 0 run data modify storage vf_macro:out resolved append from storage vf_macro:internal new
execute if score #vf_macro.cmp vf_macro matches 0 run scoreboard players set #vf_macro.seg_done vf_macro 1

# 2) Known full-template patterns for this token (covers normal usage)
execute if score #vf_macro.seg_done vf_macro matches 0 run function vf_macro:core/macro/split_patterns

# 3) Fallback: keep segment as-is
execute if score #vf_macro.seg_done vf_macro matches 0 run data modify storage vf_macro:out resolved append from storage vf_macro:internal seg

execute if data storage vf_macro:internal seg_work[0] run function vf_macro:core/macro/expand_seg_loop
