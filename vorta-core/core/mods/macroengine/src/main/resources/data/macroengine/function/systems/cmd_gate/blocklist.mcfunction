# macroengine:systems/cmd_gate/blocklist
# Developer-controlled defaults for the dynamic-command blocklist. Change the
# shipped defaults by editing THIS file in a pull request - there is no
# player-facing way to edit it. The list is only seeded when it is missing, so
# an operator's runtime additions to macroengine:engine cmd_blocklist survive
# /reload; delete that storage key to return to these defaults.
#
# Entries are command roots (the lower-cased first token), including the
# /-prefixed and minecraft:-namespaced spellings. Root-only by design: this
# is defence in depth behind the dynamic_cmd switch and the cmd.dynamic
# permission, not a general command filter (see systems/cmd_gate/check).

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:engine cmd_blocklist run data modify storage macroengine:engine cmd_blocklist set value ["op","/op","minecraft:op","deop","/deop","minecraft:deop","stop","/stop","minecraft:stop","ban","/ban","minecraft:ban","ban-ip","/ban-ip","minecraft:ban-ip","pardon","/pardon","minecraft:pardon","pardon-ip","/pardon-ip","minecraft:pardon-ip","kick","/kick","minecraft:kick","whitelist","/whitelist","minecraft:whitelist","save-off","/save-off","minecraft:save-off","reload","/reload","minecraft:reload","datapack","/datapack","minecraft:datapack"]
