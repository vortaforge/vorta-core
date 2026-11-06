# AS thrower — fire handler for dropped widget id
execute if score @s guikit.click matches 1.. run return 0
data modify storage guikit:ctx click set value {}
data modify storage guikit:ctx click.id set from storage guikit:work id
data modify storage guikit:ctx click.kind set from storage guikit:work type
execute unless data storage guikit:ctx click.kind run data modify storage guikit:ctx click.kind set value "button"
scoreboard players set @s guikit.click 1
function guikit:internal/click/run_handler
