# macroengine:systems/validate/function_id
# Checks a function id ("namespace:path/to/function") WHILE IT IS STILL DATA, before it can reach a
# `$function $(...)` line. Same idea as safe_name, which refuses ':' and '/', so the id is cut at
# ':' and '/' and every piece must pass safe_name.
# INPUT  macroengine:validate in.value   OUTPUT macroengine:validate out.valid (1b/0b), out.error
# RETURN 1 when valid, 0 when not. Tags (#ns:tag) are refused on purpose.
# USAGE  data remove storage macroengine:validate in
#        data modify storage macroengine:validate in.value set value "mypack:on_insert"
#        execute if function macroengine:systems/validate/function_id run ...
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:validate out set value {valid:0b}
data remove storage macroengine:validate fid
data modify storage macroengine:validate fid.v set string storage macroengine:validate in.value
execute unless data storage macroengine:validate fid.v run data modify storage macroengine:validate out.error set value "no value"
execute unless data storage macroengine:validate fid.v run return 0
data modify storage macroengine:text s set from storage macroengine:validate fid.v
data modify storage macroengine:text sep set value ":"
data modify storage macroengine:text keep_empty set value 1b
execute store result score #fid_n macroengine.tmp run function macroengine:core/internal/text/split
data modify storage macroengine:validate fid.parts set from storage macroengine:text out
data remove storage macroengine:text sep
data remove storage macroengine:text keep_empty
data remove storage macroengine:text out
function macroengine:core/internal/text/reset
execute unless score #fid_n macroengine.tmp matches 2 run data modify storage macroengine:validate out.error set value "expected namespace:path"
execute unless score #fid_n macroengine.tmp matches 2 run return 0
data modify storage macroengine:validate fid.segs set value []
data modify storage macroengine:validate fid.segs append from storage macroengine:validate fid.parts[0]
execute unless function macroengine:systems/validate/_fid_loop run data modify storage macroengine:validate out.error set value "bad namespace"
execute if data storage macroengine:validate out.error run return 0
data modify storage macroengine:text s set from storage macroengine:validate fid.parts[1]
data modify storage macroengine:text sep set value "/"
data modify storage macroengine:text keep_empty set value 1b
function macroengine:core/internal/text/split
data modify storage macroengine:validate fid.segs set from storage macroengine:text out
data remove storage macroengine:text sep
data remove storage macroengine:text keep_empty
data remove storage macroengine:text out
function macroengine:core/internal/text/reset
execute unless function macroengine:systems/validate/_fid_loop run data modify storage macroengine:validate out.error set value "bad path segment"
execute if data storage macroengine:validate out.error run return 0
data modify storage macroengine:validate out set value {valid:1b}
data remove storage macroengine:validate fid
return 1
