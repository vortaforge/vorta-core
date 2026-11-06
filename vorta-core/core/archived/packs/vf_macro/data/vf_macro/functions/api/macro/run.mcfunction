# PUBLIC API — vf_macro:api/macro/run
scoreboard objectives add vf_macro dummy
scoreboard players set #vf_macro.returned vf_macro 0
scoreboard players set #vf_macro.skip vf_macro 0

execute unless data storage vf_macro:in Command run tellraw @a [{"text":"[VF Macro] ","color":"red"},{"text":"ERROR: vf_macro:in Command is not set. Use api/macro/template or api/macro/parts instead of run when using template/parts.","color":"white"}]
execute unless data storage vf_macro:in Command run scoreboard players set #vf_macro.skip vf_macro 1

execute if score #vf_macro.skip vf_macro matches 0 run data modify storage vf_macro:engine Command set from storage vf_macro:in Command
execute if score #vf_macro.skip vf_macro matches 0 run data modify storage vf_macro:out Command set from storage vf_macro:in Command

execute if score #vf_macro.skip vf_macro matches 0 if data storage vf_macro:engine {Command:""} run tellraw @a [{"text":"[VF Macro] ","color":"red"},{"text":"ERROR: Command is empty","color":"white"}]
execute if score #vf_macro.skip vf_macro matches 0 if data storage vf_macro:engine {Command:""} run scoreboard players set #vf_macro.skip vf_macro 1

execute if score #vf_macro.skip vf_macro matches 0 run function vf_macro:core/engine/run

function vf_macro:core/cleanup
