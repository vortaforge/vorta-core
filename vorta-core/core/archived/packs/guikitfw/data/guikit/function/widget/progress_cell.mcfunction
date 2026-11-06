execute if score #i guikit.tmp >= #width guikit.tmp run return 0
# threshold: cell i filled if cur/max > i/width ≈ cur * width > i * max
scoreboard players operation #lhs guikit.var = #cur guikit.tmp
scoreboard players operation #lhs guikit.var *= #width guikit.tmp
scoreboard players operation #rhs guikit.var = #i guikit.tmp
scoreboard players operation #rhs guikit.var *= #max guikit.tmp
scoreboard players operation #slot guikit.tmp = #base guikit.tmp
scoreboard players operation #slot guikit.tmp += #i guikit.tmp
execute store result storage guikit:work slot int 1 run scoreboard players get #slot guikit.tmp
data modify storage guikit:work item set from storage guikit:work empty
execute if score #lhs guikit.var > #rhs guikit.var run data modify storage guikit:work item set from storage guikit:work full
data modify storage guikit:work id set value "progress"
data modify storage guikit:work type set value "progress"
data modify storage guikit:work menu set from storage guikit:ctx menu
function guikit:widget/_place_do with storage guikit:work
scoreboard players add #i guikit.tmp 1
function guikit:widget/progress_cell
