execute store result score #vf_macro.engine_y vf_macro run data get storage vf_macro:config engine_y
execute if score #vf_macro.engine_y vf_macro matches -64 run data modify block 0 -64 0 auto set value 0b
execute unless score #vf_macro.engine_y vf_macro matches -64 run data modify block 0 0 0 auto set value 0b
