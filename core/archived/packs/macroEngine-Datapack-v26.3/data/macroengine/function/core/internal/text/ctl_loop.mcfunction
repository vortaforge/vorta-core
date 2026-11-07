# macroengine:core/internal/text/ctl_loop [INTERNAL]
# Pops the first character of cf and compares it with \n, \r and \t.
data modify storage macroengine:text sc set string storage macroengine:text cf 0 1
data modify storage macroengine:text cf set string storage macroengine:text cf 1
data modify storage macroengine:text sq set from storage macroengine:text sc
execute store success score #tx_qq macroengine.tmp run data modify storage macroengine:text sq set value '\n'
execute if score #tx_qq macroengine.tmp matches 0 run return 1
data modify storage macroengine:text sq set from storage macroengine:text sc
execute store success score #tx_qq macroengine.tmp run data modify storage macroengine:text sq set value '\r'
execute if score #tx_qq macroengine.tmp matches 0 run return 1
data modify storage macroengine:text sq set from storage macroengine:text sc
execute store success score #tx_qq macroengine.tmp run data modify storage macroengine:text sq set value '\t'
execute if score #tx_qq macroengine.tmp matches 0 run return 1
scoreboard players remove #tx_sn macroengine.tmp 1
execute if score #tx_sn macroengine.tmp matches 1.. run return run function macroengine:core/internal/text/ctl_loop
return 0
