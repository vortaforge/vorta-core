# data modify storage vf_macro:in parts set value [{value:"give @p diamond 1"}]
# function vf_macro:api/macro/parts
#
# From your own storage:
# data modify storage vf_macro:in parts set value [{value:""}]
# data modify storage vf_macro:in parts[0].value set from storage mymap:cmd line

scoreboard objectives add vf_macro dummy
scoreboard players set #vf_macro.returned vf_macro 0
scoreboard players set #vf_macro.skip vf_macro 0
scoreboard players set #vf_macro.multi vf_macro 0

execute unless data storage vf_macro:in parts run tellraw @a [{"text":"[VF Macro] ","color":"red"},{"text":"ERROR: parts not set","color":"white"}]
execute unless data storage vf_macro:in parts run scoreboard players set #vf_macro.skip vf_macro 1

execute if score #vf_macro.skip vf_macro matches 0 run data modify storage vf_macro:internal resolve_list set from storage vf_macro:in parts
execute if score #vf_macro.skip vf_macro matches 0 run data modify storage vf_macro:out resolved set value []
execute if score #vf_macro.skip vf_macro matches 0 run function vf_macro:core/macro/resolve_parts
execute if score #vf_macro.skip vf_macro matches 0 run function vf_macro:core/macro/join

execute if score #vf_macro.skip vf_macro matches 0 unless data storage vf_macro:out Command run scoreboard players set #vf_macro.skip vf_macro 1
execute if score #vf_macro.skip vf_macro matches 0 if data storage vf_macro:out {Command:""} run scoreboard players set #vf_macro.skip vf_macro 1

execute if score #vf_macro.skip vf_macro matches 0 run data modify storage vf_macro:in Command set from storage vf_macro:out Command
execute if score #vf_macro.skip vf_macro matches 0 run function vf_macro:api/macro/run
execute if score #vf_macro.skip vf_macro matches 1 run function vf_macro:core/cleanup
