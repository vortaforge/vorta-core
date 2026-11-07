# macroengine:core/config/reset
# Restores every runtime config value to its default and applies it.
data remove storage macroengine:engine config
data remove storage macroengine:engine modules
scoreboard players set #sys_time macroengine.tick_flags 1
scoreboard players set #sys_player macroengine.tick_flags 1
scoreboard players set #sys_queue macroengine.tick_flags 1
scoreboard players set #sys_hud macroengine.tick_flags 1
scoreboard players set #sys_admin macroengine.tick_flags 1
function macroengine:core/config/init
function macroengine:core/config/apply
