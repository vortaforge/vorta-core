# Allow cmd_tunnel_sys:run to execute the command stored in
# cmd_tunnel_sys:input temp.cmd. OFF is the default.
scoreboard players set #dynamic cmd_tunnel_cfg 1
tellraw @s [{"text":"[cmdTunnel-Sys]","color":"aqua"}," ",{"text":"dynamic commands ON","color":"green"}]
