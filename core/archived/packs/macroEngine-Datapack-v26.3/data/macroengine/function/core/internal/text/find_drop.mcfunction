# macroengine:core/internal/text/find_drop [INTERNAL] pops the oldest match #tx_drop times
data remove storage macroengine:text idx[0]
scoreboard players remove #tx_drop macroengine.tmp 1
scoreboard players remove #tx_hits macroengine.tmp 1
execute if score #tx_drop macroengine.tmp matches 1.. run function macroengine:core/internal/text/find_drop
