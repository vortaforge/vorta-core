# macroengine:core/config/ensure
# Makes sure the runtime config is complete and applied. One cheap check per tick: the revision
# marker written by config.mcfunction plus two applied scores. It covers worlds loaded by an older
# version, where the load pipeline does not run again and new keys would never be created.
# Adding a config key means adding it to config.mcfunction and bumping config_rev there.
execute if data storage macroengine:engine {config_rev:4} if score #hook_interval macroengine.tick matches 1.. if score #queue_cap macroengine.tick matches 1.. if score #dynamic_cmd macroengine.tick_flags matches 0.. if score #perm_enforce macroengine.tick_flags matches 0.. run return 0
function macroengine:core/config/init
function macroengine:core/config/apply
