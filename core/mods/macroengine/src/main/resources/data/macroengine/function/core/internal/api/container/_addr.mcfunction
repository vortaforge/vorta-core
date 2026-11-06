# macroengine:core/internal/api/container/_addr [INTERNAL]
# Builds macroengine:container tmp.k {x,y,z[,slot][,slot2][,tx,ty,tz]} from macroengine:input.
# Every value is checked as a NUMBER first (see _num). RETURN 1 valid, 0 invalid.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data remove storage macroengine:container tmp.k
scoreboard players set #macroengine.chk macroengine.tmp 0
execute store result score #macroengine.chk macroengine.tmp run function macroengine:core/internal/api/container/_pos {x:"x",y:"y",z:"z"}
execute unless score #macroengine.chk macroengine.tmp matches 1.. run return 0
scoreboard players set #macroengine.chk macroengine.tmp 0
execute if data storage macroengine:input slot store result score #macroengine.chk macroengine.tmp run function macroengine:core/internal/api/container/_slot {f:"slot"}
execute if data storage macroengine:input slot unless score #macroengine.chk macroengine.tmp matches 1.. run return 0
scoreboard players set #macroengine.chk macroengine.tmp 0
execute if data storage macroengine:input slot2 store result score #macroengine.chk macroengine.tmp run function macroengine:core/internal/api/container/_slot {f:"slot2"}
execute if data storage macroengine:input slot2 unless score #macroengine.chk macroengine.tmp matches 1.. run return 0
scoreboard players set #macroengine.chk macroengine.tmp 0
execute if data storage macroengine:input tx store result score #macroengine.chk macroengine.tmp run function macroengine:core/internal/api/container/_pos {x:"tx",y:"ty",z:"tz"}
execute if data storage macroengine:input tx unless score #macroengine.chk macroengine.tmp matches 1.. run return 0
return 1
