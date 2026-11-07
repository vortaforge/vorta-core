
data modify storage macroengine:engine global.version set value "v26.3"
scoreboard players set #vortacraftmc.packs.macroengine.version macroengine.meta 263
function #macroengine:init
data modify storage macroengine:engine global.loaded set value 1b
tellraw @s [{"text":"[MACROENGINE]","color":"dark_aqua","italic":false}," ",{"text":"Loaded!","italic":false,"color":"green"}]
