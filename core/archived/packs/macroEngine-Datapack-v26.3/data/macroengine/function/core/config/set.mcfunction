# macroengine:core/config/set
# Sets one runtime config value, validated against the schema and applied at once.
# Unknown keys, wrong value types and unsafe strings change nothing.
#
# INPUT  macroengine:engine config_in.key    any key from docs/config.md (e.g. "hud_rate", "module_store")
#        macroengine:engine config_in.value  bool keys: 0b/1b (or any number, > 0 = on)
#                                            int keys: a number, clamped to the key's range
#                                            string keys: a string (safe characters only, length-limited)
# RETURN 1 when the value was applied, 0 otherwise.
#
# Usage:
#   data modify storage macroengine:engine config_in set value {key:"hud_rate",value:5}
#   function macroengine:core/config/set
execute unless data storage macroengine:engine config_in.value run return 0
execute unless data storage macroengine:engine config_in.key run return 0
data remove storage macroengine:validate in
data modify storage macroengine:validate in.value set from storage macroengine:engine config_in.key
execute unless function macroengine:systems/validate/safe_name run return 0
data modify storage macroengine:engine config_k set value {}
data modify storage macroengine:engine config_k.key set from storage macroengine:engine config_in.key
return run function macroengine:core/config/_set_lookup with storage macroengine:engine config_k
