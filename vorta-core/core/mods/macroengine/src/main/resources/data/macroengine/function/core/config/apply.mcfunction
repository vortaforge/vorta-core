# macroengine:core/config/apply
# Copies the runtime config in macroengine:engine config to the places the engine reads.
# Called after every load, by core/config/set and by core/config/ensure. Values the engine
# divides by are clamped here, so a hand-edited bad value in storage cannot stop the tick.
#
#   module_<name>      -> macroengine:engine modules.<name>   (read by the module guards and scans)
#   sys_<name>         -> #sys_<name> (macroengine.tick_flags)
#   tick_rate          -> #vortacraftmc.packs.macroengine.config.tick.rate (macroengine.meta)
#   hud_rate, admin_rate, hook_interval, geo_interval, interaction_interval, wand_interval,
#   perm_trigger_interval -> #<key> (macroengine.tick)
#   queue_max_depth    -> #queue_cap (macroengine.tick)
#   log_level          -> #macroengine.log_level (macroengine.log_level)
#   dynamic_cmd        -> #dynamic_cmd (macroengine.tick_flags; read by systems/cmd_gate tests)
#   perm_enforce, perm_cmd -> #perm_enforce, #perm_cmd (macroengine.tick_flags; read by api/perm/require, api/perm/check, api/cmd/*)
# The store_*, title_*, validate_max_name and reload_warn keys are read straight from storage.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:engine modules.cb set from storage macroengine:engine config.module_cb
data modify storage macroengine:engine modules.cmd set from storage macroengine:engine config.module_cmd
data modify storage macroengine:engine modules.color set from storage macroengine:engine config.module_color
data modify storage macroengine:engine modules.gamerule set from storage macroengine:engine config.module_gamerule
data modify storage macroengine:engine modules.interaction set from storage macroengine:engine config.module_interaction
data modify storage macroengine:engine modules.item set from storage macroengine:engine config.module_item
data modify storage macroengine:engine modules.macro set from storage macroengine:engine config.module_macro
data modify storage macroengine:engine modules.perm set from storage macroengine:engine config.module_perm
data modify storage macroengine:engine modules.block set from storage macroengine:engine config.module_block
data modify storage macroengine:engine modules.container set from storage macroengine:engine config.module_container
data modify storage macroengine:engine modules.store set from storage macroengine:engine config.module_store
data modify storage macroengine:engine modules.title set from storage macroengine:engine config.module_title
data modify storage macroengine:engine modules.trigger set from storage macroengine:engine config.module_trigger
data modify storage macroengine:engine modules.wand set from storage macroengine:engine config.module_wand
data modify storage macroengine:engine modules.audit set from storage macroengine:engine config.module_audit
data modify storage macroengine:engine modules.geo set from storage macroengine:engine config.module_geo
data modify storage macroengine:engine modules.hook set from storage macroengine:engine config.module_hook
data modify storage macroengine:engine modules.log set from storage macroengine:engine config.module_log
data modify storage macroengine:engine modules.logic set from storage macroengine:engine config.module_logic
data modify storage macroengine:engine modules.math set from storage macroengine:engine config.module_math
data modify storage macroengine:engine modules.rate_limit set from storage macroengine:engine config.module_rate_limit
data modify storage macroengine:engine modules.rng set from storage macroengine:engine config.module_rng
data modify storage macroengine:engine modules.sound set from storage macroengine:engine config.module_sound
data modify storage macroengine:engine modules.string set from storage macroengine:engine config.module_string
data modify storage macroengine:engine modules.text set from storage macroengine:engine config.module_text
data modify storage macroengine:engine modules.uuid set from storage macroengine:engine config.module_uuid

execute store result score #sys_time macroengine.tick_flags run data get storage macroengine:engine config.sys_time
execute store result score #sys_player macroengine.tick_flags run data get storage macroengine:engine config.sys_player
execute store result score #sys_queue macroengine.tick_flags run data get storage macroengine:engine config.sys_queue
execute store result score #sys_hud macroengine.tick_flags run data get storage macroengine:engine config.sys_hud
execute store result score #sys_admin macroengine.tick_flags run data get storage macroengine:engine config.sys_admin
execute store result score #dynamic_cmd macroengine.tick_flags run data get storage macroengine:engine config.dynamic_cmd
execute store result score #perm_enforce macroengine.tick_flags run data get storage macroengine:engine config.perm_enforce
execute store result score #perm_cmd macroengine.tick_flags run data get storage macroengine:engine config.perm_cmd

execute store result score #cfg_v macroengine.tmp run data get storage macroengine:engine config.tick_rate
execute if score #cfg_v macroengine.tmp matches ..0 run scoreboard players set #cfg_v macroengine.tmp 1
execute if score #cfg_v macroengine.tmp matches 1201.. run scoreboard players set #cfg_v macroengine.tmp 1200
scoreboard players operation #vortacraftmc.packs.macroengine.config.tick.rate macroengine.meta = #cfg_v macroengine.tmp
execute store result storage macroengine:engine config.tick_rate int 1 run scoreboard players get #cfg_v macroengine.tmp

execute store result score #cfg_v macroengine.tmp run data get storage macroengine:engine config.hud_rate
execute if score #cfg_v macroengine.tmp matches ..0 run scoreboard players set #cfg_v macroengine.tmp 1
execute if score #cfg_v macroengine.tmp matches 1201.. run scoreboard players set #cfg_v macroengine.tmp 1200
scoreboard players operation #hud_rate macroengine.tick = #cfg_v macroengine.tmp
execute store result storage macroengine:engine config.hud_rate int 1 run scoreboard players get #cfg_v macroengine.tmp

execute store result score #cfg_v macroengine.tmp run data get storage macroengine:engine config.admin_rate
execute if score #cfg_v macroengine.tmp matches ..0 run scoreboard players set #cfg_v macroengine.tmp 1
execute if score #cfg_v macroengine.tmp matches 1201.. run scoreboard players set #cfg_v macroengine.tmp 1200
scoreboard players operation #admin_rate macroengine.tick = #cfg_v macroengine.tmp
execute store result storage macroengine:engine config.admin_rate int 1 run scoreboard players get #cfg_v macroengine.tmp

execute store result score #cfg_v macroengine.tmp run data get storage macroengine:engine config.hook_interval
execute if score #cfg_v macroengine.tmp matches ..0 run scoreboard players set #cfg_v macroengine.tmp 1
execute if score #cfg_v macroengine.tmp matches 1201.. run scoreboard players set #cfg_v macroengine.tmp 1200
scoreboard players operation #hook_interval macroengine.tick = #cfg_v macroengine.tmp
execute store result storage macroengine:engine config.hook_interval int 1 run scoreboard players get #cfg_v macroengine.tmp

execute store result score #cfg_v macroengine.tmp run data get storage macroengine:engine config.geo_interval
execute if score #cfg_v macroengine.tmp matches ..0 run scoreboard players set #cfg_v macroengine.tmp 1
execute if score #cfg_v macroengine.tmp matches 1201.. run scoreboard players set #cfg_v macroengine.tmp 1200
scoreboard players operation #geo_interval macroengine.tick = #cfg_v macroengine.tmp
execute store result storage macroengine:engine config.geo_interval int 1 run scoreboard players get #cfg_v macroengine.tmp

execute store result score #cfg_v macroengine.tmp run data get storage macroengine:engine config.interaction_interval
execute if score #cfg_v macroengine.tmp matches ..0 run scoreboard players set #cfg_v macroengine.tmp 1
execute if score #cfg_v macroengine.tmp matches 1201.. run scoreboard players set #cfg_v macroengine.tmp 1200
scoreboard players operation #interaction_interval macroengine.tick = #cfg_v macroengine.tmp
execute store result storage macroengine:engine config.interaction_interval int 1 run scoreboard players get #cfg_v macroengine.tmp

execute store result score #cfg_v macroengine.tmp run data get storage macroengine:engine config.wand_interval
execute if score #cfg_v macroengine.tmp matches ..0 run scoreboard players set #cfg_v macroengine.tmp 1
execute if score #cfg_v macroengine.tmp matches 1201.. run scoreboard players set #cfg_v macroengine.tmp 1200
scoreboard players operation #wand_interval macroengine.tick = #cfg_v macroengine.tmp
execute store result storage macroengine:engine config.wand_interval int 1 run scoreboard players get #cfg_v macroengine.tmp

execute store result score #cfg_v macroengine.tmp run data get storage macroengine:engine config.perm_trigger_interval
execute if score #cfg_v macroengine.tmp matches ..0 run scoreboard players set #cfg_v macroengine.tmp 1
execute if score #cfg_v macroengine.tmp matches 1201.. run scoreboard players set #cfg_v macroengine.tmp 1200
scoreboard players operation #perm_trigger_interval macroengine.tick = #cfg_v macroengine.tmp
execute store result storage macroengine:engine config.perm_trigger_interval int 1 run scoreboard players get #cfg_v macroengine.tmp

execute store result score #cfg_v macroengine.tmp run data get storage macroengine:engine config.queue_max_depth
execute if score #cfg_v macroengine.tmp matches ..0 run scoreboard players set #cfg_v macroengine.tmp 1
execute if score #cfg_v macroengine.tmp matches 4097.. run scoreboard players set #cfg_v macroengine.tmp 4096
scoreboard players operation #queue_cap macroengine.tick = #cfg_v macroengine.tmp
execute store result storage macroengine:engine config.queue_max_depth int 1 run scoreboard players get #cfg_v macroengine.tmp

execute store result score #cfg_v macroengine.tmp run data get storage macroengine:engine config.log_level
execute if score #cfg_v macroengine.tmp matches ..-1 run scoreboard players set #cfg_v macroengine.tmp 0
execute if score #cfg_v macroengine.tmp matches 5.. run scoreboard players set #cfg_v macroengine.tmp 4
scoreboard players operation #macroengine.log_level macroengine.log_level = #cfg_v macroengine.tmp
execute store result storage macroengine:engine config.log_level int 1 run scoreboard players get #cfg_v macroengine.tmp
