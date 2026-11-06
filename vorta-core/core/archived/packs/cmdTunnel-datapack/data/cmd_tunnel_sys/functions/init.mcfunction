gamerule commandBlockOutput false
scoreboard objectives add cmd_tunnel_cfg dummy
execute unless score #dynamic cmd_tunnel_cfg matches 0.. run scoreboard players set #dynamic cmd_tunnel_cfg 0
tellraw @a [{"text":"[cmdTunnel-Sys]","color":"aqua"}," ",{"text":"Loaded","color":"green"}]
