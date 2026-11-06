# macroengine:systems/diagnostics/checks/config
# Internal: called by systems/diagnostics/collect. Checks that the runtime config exists and that
# core/config/apply has copied it to the scores the engine reads. It checks presence only and does
# not hardcode key lists or the config_rev value, so config.mcfunction stays the single source.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0

execute unless data storage macroengine:engine config run data modify storage macroengine:output diagnostics.issues append value "config.missing"
execute unless data storage macroengine:engine config_rev run data modify storage macroengine:output diagnostics.issues append value "config.rev_missing"
execute unless data storage macroengine:engine config_schema run data modify storage macroengine:output diagnostics.issues append value "config.schema_missing"

execute unless score #vortacraftmc.packs.macroengine.config.tick.rate macroengine.meta matches 1.. run data modify storage macroengine:output diagnostics.issues append value "config.not_applied:tick_rate"
execute unless score #queue_cap macroengine.tick matches 1.. run data modify storage macroengine:output diagnostics.issues append value "config.not_applied:queue_max_depth"
execute unless score #hook_interval macroengine.tick matches 1.. run data modify storage macroengine:output diagnostics.issues append value "config.not_applied:hook_interval"
execute unless score #dynamic_cmd macroengine.tick_flags matches 0.. run data modify storage macroengine:output diagnostics.issues append value "config.not_applied:dynamic_cmd"

execute if data storage macroengine:engine config{dynamic_cmd:1b} run data modify storage macroengine:output diagnostics.notices append value "security.dynamic_cmd_enabled"
