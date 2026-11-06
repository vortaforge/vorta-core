# vf_macro:string/join
# Input : storage vf_macro:string in.list  (list of plain strings)
# Output: storage vf_macro:string out     (text component compound for tellraw)
# Pure 1.16–1.20 – no set string, no sign, no armor stand required for the result

data remove storage vf_macro:string out
scoreboard players set #vf_macro.str_skip vf_macro 0

execute unless data storage vf_macro:string in.list[0] run data modify storage vf_macro:string out set value {"text":""}
execute unless data storage vf_macro:string in.list[0] run scoreboard players set #vf_macro.str_skip vf_macro 1

# 1 part → plain string (caller can use as Command)
execute if score #vf_macro.str_skip vf_macro matches 0 unless data storage vf_macro:string in.list[1] run data modify storage vf_macro:string out set from storage vf_macro:string in.list[0]
execute if score #vf_macro.str_skip vf_macro matches 0 unless data storage vf_macro:string in.list[1] run scoreboard players set #vf_macro.str_skip vf_macro 1

# 2+ parts → build {"text":"","extra":[{"text":"p0"},{"text":"p1"},...]}
execute if score #vf_macro.str_skip vf_macro matches 0 run data modify storage vf_macro:string out set value {"text":"","extra":[]}

execute if score #vf_macro.str_skip vf_macro matches 0 if data storage vf_macro:string in.list[0] run data modify storage vf_macro:string out.extra append value {"text":""}
execute if score #vf_macro.str_skip vf_macro matches 0 if data storage vf_macro:string in.list[0] run data modify storage vf_macro:string out.extra[-1].text set from storage vf_macro:string in.list[0]

execute if score #vf_macro.str_skip vf_macro matches 0 if data storage vf_macro:string in.list[1] run data modify storage vf_macro:string out.extra append value {"text":""}
execute if score #vf_macro.str_skip vf_macro matches 0 if data storage vf_macro:string in.list[1] run data modify storage vf_macro:string out.extra[-1].text set from storage vf_macro:string in.list[1]

execute if score #vf_macro.str_skip vf_macro matches 0 if data storage vf_macro:string in.list[2] run data modify storage vf_macro:string out.extra append value {"text":""}
execute if score #vf_macro.str_skip vf_macro matches 0 if data storage vf_macro:string in.list[2] run data modify storage vf_macro:string out.extra[-1].text set from storage vf_macro:string in.list[2]

execute if score #vf_macro.str_skip vf_macro matches 0 if data storage vf_macro:string in.list[3] run data modify storage vf_macro:string out.extra append value {"text":""}
execute if score #vf_macro.str_skip vf_macro matches 0 if data storage vf_macro:string in.list[3] run data modify storage vf_macro:string out.extra[-1].text set from storage vf_macro:string in.list[3]

execute if score #vf_macro.str_skip vf_macro matches 0 if data storage vf_macro:string in.list[4] run data modify storage vf_macro:string out.extra append value {"text":""}
execute if score #vf_macro.str_skip vf_macro matches 0 if data storage vf_macro:string in.list[4] run data modify storage vf_macro:string out.extra[-1].text set from storage vf_macro:string in.list[4]

execute if score #vf_macro.str_skip vf_macro matches 0 if data storage vf_macro:string in.list[5] run data modify storage vf_macro:string out.extra append value {"text":""}
execute if score #vf_macro.str_skip vf_macro matches 0 if data storage vf_macro:string in.list[5] run data modify storage vf_macro:string out.extra[-1].text set from storage vf_macro:string in.list[5]

execute if score #vf_macro.str_skip vf_macro matches 0 if data storage vf_macro:string in.list[6] run data modify storage vf_macro:string out.extra append value {"text":""}
execute if score #vf_macro.str_skip vf_macro matches 0 if data storage vf_macro:string in.list[6] run data modify storage vf_macro:string out.extra[-1].text set from storage vf_macro:string in.list[6]

execute if score #vf_macro.str_skip vf_macro matches 0 if data storage vf_macro:string in.list[7] run data modify storage vf_macro:string out.extra append value {"text":""}
execute if score #vf_macro.str_skip vf_macro matches 0 if data storage vf_macro:string in.list[7] run data modify storage vf_macro:string out.extra[-1].text set from storage vf_macro:string in.list[7]

scoreboard players set #vf_macro.str_skip vf_macro 0
