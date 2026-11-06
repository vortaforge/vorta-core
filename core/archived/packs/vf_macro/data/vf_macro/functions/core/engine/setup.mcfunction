# Ensure chunk + command block exist
forceload add 0 0
execute unless data storage vf_macro:config engine_y run data modify storage vf_macro:config engine_y set value 0
execute store result score #vf_macro.engine_y vf_macro run data get storage vf_macro:config engine_y

# Always re-place so the block is valid even if chunk just forceloaded
execute if score #vf_macro.engine_y vf_macro matches -64 run setblock 0 -64 0 air
execute if score #vf_macro.engine_y vf_macro matches -64 run setblock 0 -64 0 minecraft:command_block{Command:"",auto:0b,TrackOutput:0b} replace
execute unless score #vf_macro.engine_y vf_macro matches -64 run setblock 0 0 0 air
execute unless score #vf_macro.engine_y vf_macro matches -64 run setblock 0 0 0 minecraft:command_block{Command:"",auto:0b,TrackOutput:0b} replace

