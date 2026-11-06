# Write command and rising-edge pulse auto:0 → auto:1
execute store result score #vf_macro.engine_y vf_macro run data get storage vf_macro:config engine_y

# Y = -64
execute if score #vf_macro.engine_y vf_macro matches -64 run data modify block 0 -64 0 auto set value 0b
execute if score #vf_macro.engine_y vf_macro matches -64 run data modify block 0 -64 0 Command set from storage vf_macro:engine Command
execute if score #vf_macro.engine_y vf_macro matches -64 run data modify block 0 -64 0 auto set value 1b

# Y = 0 (default)
execute unless score #vf_macro.engine_y vf_macro matches -64 run data modify block 0 0 0 auto set value 0b
execute unless score #vf_macro.engine_y vf_macro matches -64 run data modify block 0 0 0 Command set from storage vf_macro:engine Command
execute unless score #vf_macro.engine_y vf_macro matches -64 run data modify block 0 0 0 auto set value 1b

schedule function vf_macro:core/engine/reset 4t replace
