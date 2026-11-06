# Show last captured and last executed input commands.
tellraw @s [{"text":"[TunnelScript] last captured: ","color":"aqua"},{"storage":"tunnelscript:minecart","nbt":"last_captured","color":"white","plain":true,"interpret":false}]
tellraw @s [{"text":"[TunnelScript] last executed: ","color":"green"},{"storage":"tunnelscript:minecart","nbt":"last_executed","color":"white","plain":true,"interpret":false}]
