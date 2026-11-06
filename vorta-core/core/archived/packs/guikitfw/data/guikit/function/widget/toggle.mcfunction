execute unless data storage guikit:draw w.off run data modify storage guikit:draw w.off set value "minecraft:gray_dye"
execute unless data storage guikit:draw w.item run data modify storage guikit:draw w.item set value "minecraft:lime_dye"
data modify storage guikit:work key set from storage guikit:draw w.key
execute if data storage guikit:draw w.toggle.score run data modify storage guikit:work key set from storage guikit:draw w.toggle.score
execute if data storage guikit:work key run function guikit:widget/toggle_visual with storage guikit:work
function guikit:widget/_place
