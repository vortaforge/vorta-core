# macroengine:core/config/_set_str [MACRO, INTERNAL]  $(key) is a schema key
# The string must pass safe_name (no quotes, backslashes, braces, whitespace...) and fit the key's max length.
data remove storage macroengine:validate in
data modify storage macroengine:validate in.value set from storage macroengine:engine config_in.value
execute unless function macroengine:systems/validate/safe_name run return 0
execute store result score #cfg_len macroengine.tmp run data get storage macroengine:engine config_in.value
execute store result score #cfg_max macroengine.tmp run data get storage macroengine:engine config_sc.max
execute if score #cfg_len macroengine.tmp > #cfg_max macroengine.tmp run return 0
$data modify storage macroengine:engine config.$(key) set string storage macroengine:engine config_in.value
function macroengine:core/config/apply
return 1
