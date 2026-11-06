# Reads storage guikit:cond.current (or guikit:act w.condition)
scoreboard players set #cond guikit.tmp 1
execute unless data storage guikit:cond current.type if data storage guikit:act w.condition run data modify storage guikit:cond current set from storage guikit:act w.condition
execute unless data storage guikit:cond current.type run return 0
data modify storage guikit:work ctype set from storage guikit:cond current.type
function guikit:cond/dispatch with storage guikit:work
