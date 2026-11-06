# Private — scheduled by if_function/run
# Maps the (now-available) return state + command-block success into #vf_macro.if_success
# Runs a few ticks after the command-block engine has executed the target function.

# 1. First check whether the command block itself succeeded.
#    SuccessCount == 0 means the command was invalid / function did not exist / etc.
# Respects vf_macro:config engine_y (0 = default/universal, -64 = optional for 1.18+)
execute store result score #vf_macro.engine_y vf_macro run data get storage vf_macro:config engine_y
execute if score #vf_macro.engine_y vf_macro matches -64 store result score #vf_macro.tmp vf_macro run data get block 0 -64 0 SuccessCount
execute unless score #vf_macro.engine_y vf_macro matches -64 store result score #vf_macro.tmp vf_macro run data get block 0 0 0 SuccessCount
execute if score #vf_macro.tmp vf_macro matches 0 run scoreboard players set #vf_macro.if_success vf_macro 0
execute if score #vf_macro.tmp vf_macro matches 1.. run scoreboard players set #vf_macro.if_success vf_macro 1

# 2. Override with explicit return API results (higher priority)
#    Fail-return always forces failure
execute if score #vf_macro.returned vf_macro matches 1 if data storage vf_macro:out {return_success:0b} run scoreboard players set #vf_macro.if_success vf_macro 0

#    Success-return (or return <value>) forces success
execute if score #vf_macro.returned vf_macro matches 1 if data storage vf_macro:out {return_success:1b} run scoreboard players set #vf_macro.if_success vf_macro 1

# Optional debug
# tellraw @a [{"text":"[VF Macro] if_function → ","color":"gray"},{"score":{"name":"#vf_macro.if_success","objective":"vf_macro"},"color":"yellow"},{"text":" (returned=","color":"dark_gray"},{"score":{"name":"#vf_macro.returned","objective":"vf_macro"},"color":"dark_gray"},{"text":", SuccessCount=","color":"dark_gray"},{"score":{"name":"#vf_macro.tmp","objective":"vf_macro"},"color":"dark_gray"},{"text":")","color":"dark_gray"}]
