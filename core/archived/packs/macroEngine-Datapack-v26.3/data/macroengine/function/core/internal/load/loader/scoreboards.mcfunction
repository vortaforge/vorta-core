# macroengine:core/internal/load/loader/scoreboards
# (moved from macroengine:core/internal/load/load/scoreboards in v26.3 — load/ vs loader/
#  separates gate/confirmation logic from the actual init routines)

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0

scoreboard objectives add macroengine.tmp dummy
scoreboard objectives add macroengine.anvil_t dummy
scoreboard objectives add macroengine.meta dummy
scoreboard objectives add macroengine.time dummy
scoreboard objectives add macroengine_run trigger
scoreboard objectives add macroengine_action trigger
scoreboard objectives add macroengine.pre_version dummy
scoreboard objectives add macroengine.pid dummy
scoreboard objectives add macroengine.freeze_id dummy
scoreboard objectives add macroengine.health health
scoreboard objectives add macroengine.food food
scoreboard objectives add macroengine.rightClick minecraft.used:minecraft.carrot_on_a_stick
scoreboard objectives add macroengine.hook_online dummy
scoreboard objectives add macroengine.hook_deaths deathCount
scoreboard objectives add macroengine.hook_placed dummy
scoreboard objectives add macroengine.hook_lvl dummy
scoreboard objectives add macroengine.hook_lvl_new dummy
scoreboard objectives add macroengine.hook_sneak dummy
scoreboard objectives add macroengine.hook_sprint dummy
scoreboard objectives add macroengine.hook_elytra dummy
scoreboard objectives add macroengine.hook_tool_used dummy
scoreboard objectives add macroengine.hook_item_used dummy
scoreboard objectives add macroengine.hook_entity_killed dummy
scoreboard objectives add macroengine.hook_using_item dummy
scoreboard objectives add macroengine.hook_killed_by_arrow dummy
scoreboard objectives add macroengine.hook_hero_of_the_village dummy
scoreboard objectives add macroengine.hook_dim_changed dummy
scoreboard objectives add macroengine.hook_traded dummy
scoreboard objectives add macroengine.tick dummy
scoreboard objectives add macroengine.tick_flags dummy
scoreboard objectives add macroengine.Flags dummy
scoreboard objectives add macroengine.hook_jump minecraft.custom:minecraft.jump
scoreboard objectives add macroengine.hook_open_chest minecraft.custom:minecraft.open_chest
scoreboard objectives add macroengine.hook_drop minecraft.custom:minecraft.drop
scoreboard objectives add macroengine.hook_target_hit minecraft.custom:minecraft.target_hit
scoreboard objectives add macroengine.hook_eat dummy
scoreboard objectives add macroengine.hook_fish dummy
scoreboard objectives add macroengine.log_level dummy
scoreboard objectives add macroengine.gamerule dummy
scoreboard objectives add macroengine.state dummy
scoreboard objectives add macroengine.rnd_idx dummy

execute unless score #macroengine.log_level macroengine.log_level matches 0.. run scoreboard players set #macroengine.log_level macroengine.log_level 3
scoreboard players set @a macroengine.hook_online 1
