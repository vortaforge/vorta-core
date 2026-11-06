# DL Tick — Simplified Dispatch (no runtime channel registry)
# Rates come from the runtime config (core/config/apply); there is no JSON-configurable list.
# Each system can be toggled on/off via a scoreboard flag (default 1 = on),
# set with: function macroengine:systems/flag/toggle_system {system:"time"}
# Valid system ids: time | player | queue | hud | admin
#
# time_systems / player_systems / queue_systems: every tick (rate 1)
# hud_systems: every config.hud_rate engine ticks (default 2)
# admin_systems: every config.admin_rate engine ticks (default 4)
# The rates are set by core/config/apply from macroengine:engine config.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players add #tick_ctr macroengine.tick 1

execute unless score #sys_time macroengine.tick_flags matches 0 run function macroengine:core/tick/time_systems
execute unless score #sys_player macroengine.tick_flags matches 0 run function macroengine:core/tick/player_systems
execute unless score #sys_queue macroengine.tick_flags matches 0 run function macroengine:core/tick/queue_systems

scoreboard players operation #hud_mod macroengine.tick = #tick_ctr macroengine.tick
scoreboard players operation #hud_mod macroengine.tick %= #hud_rate macroengine.tick
execute if score #hud_mod macroengine.tick matches 0 unless score #sys_hud macroengine.tick_flags matches 0 run function macroengine:core/tick/hud_systems

scoreboard players operation #admin_mod macroengine.tick = #tick_ctr macroengine.tick
scoreboard players operation #admin_mod macroengine.tick %= #admin_rate macroengine.tick
execute if score #admin_mod macroengine.tick matches 0 unless score #sys_admin macroengine.tick_flags matches 0 run function macroengine:core/tick/admin_systems
