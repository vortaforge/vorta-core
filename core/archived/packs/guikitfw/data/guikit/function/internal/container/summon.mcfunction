# Summon per-player entity container (guigen minecart / chest boat)
data modify storage guikit:work ctype set from storage guikit:cfg container
data modify storage guikit:work id set from storage guikit:in menu
execute if data storage guikit:in menu run function guikit:internal/draw/load_menu with storage guikit:work
execute if data storage guikit:draw menu.container run data modify storage guikit:work ctype set from storage guikit:draw menu.container
execute unless data storage guikit:work ctype run data modify storage guikit:work ctype set value "chest_minecart"

execute if data storage guikit:work {ctype:"oak_chest_boat"} run return run summon minecraft:oak_chest_boat ~ ~1.2 ~ {Tags:["guikit.cart","guikit.new"],Invulnerable:1b,NoGravity:1b,Silent:1b}
execute if data storage guikit:work {ctype:"birch_chest_boat"} run return run summon minecraft:birch_chest_boat ~ ~1.2 ~ {Tags:["guikit.cart","guikit.new"],Invulnerable:1b,NoGravity:1b,Silent:1b}
execute if data storage guikit:work {ctype:"spruce_chest_boat"} run return run summon minecraft:spruce_chest_boat ~ ~1.2 ~ {Tags:["guikit.cart","guikit.new"],Invulnerable:1b,NoGravity:1b,Silent:1b}
execute if data storage guikit:work {ctype:"jungle_chest_boat"} run return run summon minecraft:jungle_chest_boat ~ ~1.2 ~ {Tags:["guikit.cart","guikit.new"],Invulnerable:1b,NoGravity:1b,Silent:1b}
execute if data storage guikit:work {ctype:"acacia_chest_boat"} run return run summon minecraft:acacia_chest_boat ~ ~1.2 ~ {Tags:["guikit.cart","guikit.new"],Invulnerable:1b,NoGravity:1b,Silent:1b}
execute if data storage guikit:work {ctype:"dark_oak_chest_boat"} run return run summon minecraft:dark_oak_chest_boat ~ ~1.2 ~ {Tags:["guikit.cart","guikit.new"],Invulnerable:1b,NoGravity:1b,Silent:1b}
execute if data storage guikit:work {ctype:"mangrove_chest_boat"} run return run summon minecraft:mangrove_chest_boat ~ ~1.2 ~ {Tags:["guikit.cart","guikit.new"],Invulnerable:1b,NoGravity:1b,Silent:1b}
execute if data storage guikit:work {ctype:"cherry_chest_boat"} run return run summon minecraft:cherry_chest_boat ~ ~1.2 ~ {Tags:["guikit.cart","guikit.new"],Invulnerable:1b,NoGravity:1b,Silent:1b}
execute if data storage guikit:work {ctype:"bamboo_chest_raft"} run return run summon minecraft:bamboo_chest_raft ~ ~1.2 ~ {Tags:["guikit.cart","guikit.new"],Invulnerable:1b,NoGravity:1b,Silent:1b}
execute if data storage guikit:work {ctype:"chest_minecart"} run return run summon minecraft:chest_minecart ~ ~1.2 ~ {Tags:["guikit.cart","guikit.new"],Invulnerable:1b,NoGravity:1b,Silent:1b,CustomNameVisible:0b}
execute if data storage guikit:work {ctype:"hopper_minecart"} run return run summon minecraft:hopper_minecart ~ ~1.2 ~ {Tags:["guikit.cart","guikit.new"],Invulnerable:1b,NoGravity:1b,Silent:1b,CustomNameVisible:0b}