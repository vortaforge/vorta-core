# macroengine:core/internal/api/store/_resolve [INTERNAL]
# tmp.segs[0] is a name between two '%'. Appends exactly one entry to tmp.frags.
data modify storage macroengine:store tmp.nm set from storage macroengine:store tmp.segs[0]
data remove storage macroengine:store tmp.val
data remove storage macroengine:store tmp.raw
execute store result score #st_len macroengine.tmp run data get storage macroengine:store tmp.nm
execute if score #st_len macroengine.tmp matches 0 run data modify storage macroengine:store tmp.val set value "%"
execute unless data storage macroengine:store tmp.val run function macroengine:core/internal/api/store/_dispatch
execute if data storage macroengine:store tmp.val run data modify storage macroengine:store tmp.frags append from storage macroengine:store tmp.val
execute if data storage macroengine:store tmp.val run return 1
# unknown: keep "%name%" exactly as written
execute if data storage macroengine:engine config{store_keep_unknown:0b} run return 1
data modify storage macroengine:store tmp.frags append value "%"
data modify storage macroengine:store tmp.frags append from storage macroengine:store tmp.nm
data modify storage macroengine:store tmp.frags append value "%"
