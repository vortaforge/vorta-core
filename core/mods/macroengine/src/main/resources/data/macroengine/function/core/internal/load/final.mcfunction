execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0

data modify storage macroengine:engine global.version set value "v26.3"
scoreboard players set #vortacraftmc.packs.macroengine.version macroengine.meta 263
function #macroengine:init
data modify storage macroengine:engine global.loaded set value 1b
tellraw @s [{"text":"[MACROENGINE]","color":"dark_aqua","italic":false}," ",{"text":"Loaded!","italic":false,"color":"green"}]
