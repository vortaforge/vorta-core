function guikit:runtime/menu_hooks_close
function #guikit:on_close
function guikit:internal/container/load_pos
# Clear items always for this closer
function guikit:internal/container/clear_block with storage guikit:work
# Only setblock air when nobody else has this kiosk open (same bx/by/bz + timer)
scoreboard players set #others guikit.tmp 0
scoreboard players operation #bx guikit.tmp = @s guikit.bx
scoreboard players operation #by guikit.tmp = @s guikit.by
scoreboard players operation #bz guikit.tmp = @s guikit.bz
execute as @a[scores={guikit.timer=1..,guikit.mode=1}] if score @s guikit.bx = #bx guikit.tmp if score @s guikit.by = #by guikit.tmp if score @s guikit.bz = #bz guikit.tmp run scoreboard players add #others guikit.tmp 1
# others includes self — remove block only if count is 1
execute if score #others guikit.tmp matches 1 run function guikit:internal/container/remove_block with storage guikit:work

clear @s *[custom_data~{guikit:{widget:1}}]
scoreboard players reset @s guikit.timer
scoreboard players reset @s guikit.page
scoreboard players reset @s guikit.click
scoreboard players reset @s guikit.uid
scoreboard players reset @s guikit.mode
scoreboard players reset @s guikit.bx
scoreboard players reset @s guikit.by
scoreboard players reset @s guikit.bz
data remove storage guikit:ctx menu
data remove storage guikit:ctx actions
data remove storage guikit:ctx click
