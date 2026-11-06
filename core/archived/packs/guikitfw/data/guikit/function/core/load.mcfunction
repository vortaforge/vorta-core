# guikit :: core/load
# Framework bootstrap. Does not seed any menu.

scoreboard objectives add guikit.pid dummy
scoreboard objectives add guikit.uid dummy
scoreboard objectives add guikit.timer dummy
scoreboard objectives add guikit.tmax dummy
scoreboard objectives add guikit.page dummy
scoreboard objectives add guikit.click dummy
scoreboard objectives add guikit.dirty dummy
scoreboard objectives add guikit.tmp dummy
scoreboard objectives add guikit.const dummy
scoreboard objectives add guikit.cd dummy
scoreboard objectives add guikit.mode dummy
scoreboard objectives add guikit.bz dummy
scoreboard objectives add guikit.by dummy
scoreboard objectives add guikit.bx dummy
scoreboard objectives add guikit.var dummy
scoreboard objectives add guikit.drop minecraft.custom:minecraft.drop
scoreboard objectives add guikit.last trigger
scoreboard objectives add guikit.close trigger

scoreboard players set #version guikit.const 2
execute unless score #next_pid guikit.pid matches 1.. run scoreboard players set #next_pid guikit.pid 1
execute unless score #next_uid guikit.uid matches 1.. run scoreboard players set #next_uid guikit.uid 1

# Storage defaults (empty — framework only)
execute unless data storage guikit:lib menus run data modify storage guikit:lib menus set value {}
execute unless data storage guikit:lib order run data modify storage guikit:lib order set value []
execute unless data storage guikit:reg menus run data modify storage guikit:reg menus set value {}
execute unless data storage guikit:cfg click_detection run data modify storage guikit:cfg click_detection set value ["shift"]
execute unless data storage guikit:cfg container run data modify storage guikit:cfg container set value "chest_minecart"
execute unless data storage guikit:cfg timer run data modify storage guikit:cfg timer set value 900
execute unless data storage guikit:cfg distance_close run data modify storage guikit:cfg distance_close set value 8
execute unless data storage guikit:cfg follow run data modify storage guikit:cfg follow set value 1b
execute unless data storage guikit:cfg dynamic_cmd run data modify storage guikit:cfg dynamic_cmd set value 0b

function guikit:internal/util/clear_scratch
function #guikit:register

scoreboard players enable @a guikit.last
scoreboard players enable @a guikit.close
