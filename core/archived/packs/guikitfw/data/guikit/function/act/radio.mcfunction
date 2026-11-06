data modify storage guikit:work key set from storage guikit:act w.radio.score
execute store result score #val guikit.tmp run data get storage guikit:act w.radio.value
function guikit:act/_radio_set with storage guikit:work
execute if data storage guikit:act w.functions[0] run function guikit:act/_functions
