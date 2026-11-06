# macroengine:systems/diagnostics/checks/runtime
# Internal: called by systems/diagnostics/collect. Engine load flag, tick pause state, log and audit.
# Issue:   engine.not_loaded
# Notices: tick.paused_storage  tick.paused_config  log.debug_level  audit.buffer_full

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0

execute unless data storage macroengine:engine global{loaded:1b} run data modify storage macroengine:output diagnostics.issues append value "engine.not_loaded"
execute if data storage macroengine:engine tick{paused:1b} run data modify storage macroengine:output diagnostics.notices append value "tick.paused_storage"
execute if score #vortacraftmc.packs.macroengine.config.tick.pause macroengine.meta matches 1 run data modify storage macroengine:output diagnostics.notices append value "tick.paused_config"

execute store result storage macroengine:output diagnostics.log.level int 1 run scoreboard players get #macroengine.log_level macroengine.log_level
execute store result storage macroengine:output diagnostics.log.buffered int 1 run data get storage macroengine:engine log_display
execute if score #macroengine.log_level macroengine.log_level matches 4 run data modify storage macroengine:output diagnostics.notices append value "log.debug_level"

execute store result storage macroengine:output diagnostics.audit.count int 1 run data get storage macroengine:audit entries
execute unless data storage macroengine:engine modules{audit:0b} if data storage macroengine:output diagnostics.audit{count:100} run data modify storage macroengine:output diagnostics.notices append value "audit.buffer_full"
