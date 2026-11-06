data modify storage guikit:work me set from entity @s UUID
execute store success score #uuid guikit.tmp run data modify storage guikit:work me set from storage guikit:work thrower
execute if score #uuid guikit.tmp matches 0 run tag @s add guikit.thrower
