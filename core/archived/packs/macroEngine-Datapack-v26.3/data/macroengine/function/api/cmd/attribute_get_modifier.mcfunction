
execute if data storage macroengine:engine modules{cmd:0b} run return 0
execute if score #perm_cmd macroengine.tick_flags matches 1 run data modify storage macroengine:perm_require in set value {perm:"cmd.attribute_get_modifier"}
execute if score #perm_cmd macroengine.tick_flags matches 1 unless function macroengine:api/perm/require run return 0
$execute store result storage macroengine:output result double 1 run attribute @a[name=$(player),limit=1] $(attribute) modifier value get $(id)