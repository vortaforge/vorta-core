scoreboard objectives add vf_macro dummy
scoreboard players set #vf_macro.returned vf_macro 0
scoreboard players set #vf_macro.if_success vf_macro 0
scoreboard players set #vf_macro.version vf_macro 191
scoreboard players set #0 vf_macro 0
scoreboard players set #1 vf_macro 1
scoreboard players set #vf_macro.skip vf_macro 0
scoreboard players set #vf_macro.multi vf_macro 0
scoreboard players set #vf_macro.resolve_done vf_macro 0
scoreboard players set #vf_macro.engine_y vf_macro 0
scoreboard players set #vf_macro.expanded vf_macro 0
scoreboard players set #vf_macro.free_done vf_macro 0
scoreboard players set #vf_macro.cmp vf_macro 0
scoreboard players set #vf_macro.key_found vf_macro 0
scoreboard players set #vf_macro.force_ok vf_macro 0

data modify storage vf_macro:internal version set value "1.9.1"

data remove storage vf_macro:args amount
data remove storage vf_macro:args cmd
data remove storage vf_macro:args count
data remove storage vf_macro:args func
data remove storage vf_macro:args id
data remove storage vf_macro:args key
data remove storage vf_macro:args msg
data remove storage vf_macro:args name
data remove storage vf_macro:args path
data remove storage vf_macro:args player
data remove storage vf_macro:args pos
data remove storage vf_macro:args score
data remove storage vf_macro:args selector
data remove storage vf_macro:args storage
data remove storage vf_macro:args target
data remove storage vf_macro:args text
data remove storage vf_macro:args value
data remove storage vf_macro:args x
data remove storage vf_macro:args y
data remove storage vf_macro:args z

execute unless data storage vf_macro:config track_output run data modify storage vf_macro:config track_output set value 0b
execute unless data storage vf_macro:config engine_y run data modify storage vf_macro:config engine_y set value 0
execute unless data storage vf_macro:config multi_exec run data modify storage vf_macro:config multi_exec set value 0b

forceload add 0 0
forceload add 1 1
setblock 0 0 0 minecraft:command_block{Command:"",auto:0b,TrackOutput:0b} replace

tellraw @a [{"text":"[VF Macro] ","color":"aqua"},{"text":"v1.9.1 loaded (multi_exec fix, cleanup fix).","color":"white"}]