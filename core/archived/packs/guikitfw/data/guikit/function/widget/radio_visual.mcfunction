# macro $(key)
$execute if score @s $(key) = #val guikit.tmp if data storage guikit:draw w.radio.on_item run data modify storage guikit:draw w.item set from storage guikit:draw w.radio.on_item
$execute if score @s $(key) = #val guikit.tmp unless data storage guikit:draw w.radio.on_item run data modify storage guikit:draw w.item set value "minecraft:lime_dye"
