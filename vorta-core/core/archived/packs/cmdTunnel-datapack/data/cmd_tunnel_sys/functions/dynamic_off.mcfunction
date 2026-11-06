# Block cmd_tunnel_sys:run at the gate (default).
scoreboard players set #dynamic cmd_tunnel_cfg 0
tellraw @s [{"text":"[cmdTunnel-Sys]","color":"aqua"}," ",{"text":"dynamic commands OFF","color":"yellow"}]
