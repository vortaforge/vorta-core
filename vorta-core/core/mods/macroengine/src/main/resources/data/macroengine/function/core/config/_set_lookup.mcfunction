# macroengine:core/config/_set_lookup [MACRO, INTERNAL]
# $(key) already passed safe_name. It only READS the schema here; a key that is not a schema entry
# (including dotted paths into an entry) leaves config_sc without a type and nothing is written.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data remove storage macroengine:engine config_sc
$data modify storage macroengine:engine config_sc set from storage macroengine:engine config_schema.$(key)
execute unless data storage macroengine:engine config_sc.t run return 0
execute if data storage macroengine:engine config_sc{t:"bool"} run return run function macroengine:core/config/_set_bool with storage macroengine:engine config_k
execute if data storage macroengine:engine config_sc{t:"int"} run return run function macroengine:core/config/_set_int with storage macroengine:engine config_k
execute if data storage macroengine:engine config_sc{t:"str"} run return run function macroengine:core/config/_set_str with storage macroengine:engine config_k
return 0
