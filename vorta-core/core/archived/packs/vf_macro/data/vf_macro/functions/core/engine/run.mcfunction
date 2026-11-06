scoreboard objectives add vf_macro dummy
scoreboard players set #vf_macro.skip vf_macro 0

execute unless data storage vf_macro:engine Command run tellraw @a [{"text":"[VF Macro] ","color":"red"},{"text":"ERROR: engine Command empty","color":"white"}]
execute unless data storage vf_macro:engine Command run scoreboard players set #vf_macro.skip vf_macro 1

# Keep a stable copy for delayed pulse
execute if score #vf_macro.skip vf_macro matches 0 run data modify storage vf_macro:engine pending set from storage vf_macro:engine Command

execute if score #vf_macro.skip vf_macro matches 0 run function vf_macro:core/engine/setup
# Pulse next tick so forceload has time to apply (critical on 1.19.4 and below)
execute if score #vf_macro.skip vf_macro matches 0 run schedule function vf_macro:core/engine/exec_delayed 1t replace
