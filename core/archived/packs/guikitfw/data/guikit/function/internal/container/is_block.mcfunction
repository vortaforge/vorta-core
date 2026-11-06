# Sets #block guikit.tmp = 1 if menu/cfg container is a block kiosk type
scoreboard players set #block guikit.tmp 0
data modify storage guikit:work ctype set from storage guikit:cfg container
execute if data storage guikit:draw menu.container run data modify storage guikit:work ctype set from storage guikit:draw menu.container
# nested form: menu.container.type
execute if data storage guikit:draw menu.container.type run data modify storage guikit:work ctype set from storage guikit:draw menu.container.type
execute if data storage guikit:work {ctype:"chest"} run scoreboard players set #block guikit.tmp 1
execute if data storage guikit:work {ctype:"trapped_chest"} run scoreboard players set #block guikit.tmp 1
execute if data storage guikit:work {ctype:"barrel"} run scoreboard players set #block guikit.tmp 1
execute if data storage guikit:work {ctype:"hopper"} run scoreboard players set #block guikit.tmp 1
execute if data storage guikit:work {ctype:"dropper"} run scoreboard players set #block guikit.tmp 1
execute if data storage guikit:work {ctype:"dispenser"} run scoreboard players set #block guikit.tmp 1
execute if data storage guikit:work {ctype:"ender_chest"} run scoreboard players set #block guikit.tmp 1
execute if data storage guikit:work {ctype:"large_chest"} run scoreboard players set #block guikit.tmp 1
