execute if data storage macroengine:engine modules{interaction:0b} run return 0
$summon minecraft:interaction ~ ~ ~ {width:$(width), height:$(height), response:$(response), Tags:["macroengine.interaction","macroengine.ia_new"]}

$tag @e[type=minecraft:interaction,tag=macroengine.ia_new,limit=1,sort=nearest] add $(tag)
tag @e[tag=macroengine.ia_new] remove macroengine.ia_new