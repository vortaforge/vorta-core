# w.radio.score, w.radio.value, on/off items
data modify storage guikit:work key set from storage guikit:draw w.radio.score
execute store result score #val guikit.tmp run data get storage guikit:draw w.radio.value
execute unless data storage guikit:draw w.radio.off_item run data modify storage guikit:draw w.item set value "minecraft:gray_dye"
execute if data storage guikit:draw w.radio.off_item run data modify storage guikit:draw w.item set from storage guikit:draw w.radio.off_item
execute if data storage guikit:work key run function guikit:widget/radio_visual with storage guikit:work
function guikit:widget/_place
