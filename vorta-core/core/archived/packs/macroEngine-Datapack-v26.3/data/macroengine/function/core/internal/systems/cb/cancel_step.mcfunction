# macroengine:systems/cb/internal/cancel_step
# Pops the first entry of _cb_cwork; keeps it in cb_queue unless its id == #cb_cid.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:engine _cb_centry set from storage macroengine:engine _cb_cwork[0]
data remove storage macroengine:engine _cb_cwork[0]
scoreboard players set #cb_eid macroengine.tmp 0
execute store result score #cb_eid macroengine.tmp run data get storage macroengine:engine _cb_centry.id
execute if score #cb_eid macroengine.tmp = #cb_cid macroengine.tmp run scoreboard players add #cb_ccount macroengine.tmp 1
execute unless score #cb_eid macroengine.tmp = #cb_cid macroengine.tmp run data modify storage macroengine:engine cb_queue append from storage macroengine:engine _cb_centry
data remove storage macroengine:engine _cb_centry
execute if data storage macroengine:engine _cb_cwork[0] run function macroengine:core/internal/systems/cb/cancel_step
