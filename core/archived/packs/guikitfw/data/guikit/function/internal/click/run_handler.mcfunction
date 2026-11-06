# Snapshot click before anything mutates storage
data modify storage guikit:act click set from storage guikit:ctx click

function guikit:act/_resolve
execute unless data storage guikit:act w.kind run data modify storage guikit:act w.kind set from storage guikit:act click.kind
execute unless data storage guikit:act w.kind run data modify storage guikit:act w.kind set from storage guikit:ctx click.kind

# condition
scoreboard players set #cond guikit.tmp 1
execute if data storage guikit:act w.condition run data modify storage guikit:cond current set from storage guikit:act w.condition
execute if data storage guikit:act w.condition run function guikit:cond/check
execute if score #cond guikit.tmp matches 0 run return run function guikit:internal/click/fail_cond

# cooldown (only if this widget defines it)
scoreboard players set #cd_block guikit.tmp 0
execute if data storage guikit:act w.cooldown_ticks run function guikit:internal/click/cd_check
execute if score #cd_block guikit.tmp matches 1 run return 0

# costs
scoreboard players set #cost_fail guikit.tmp 0
execute if data storage guikit:act w.costs[0] run function guikit:internal/click/cost_check
execute if score #cost_fail guikit.tmp matches 1 run return run function guikit:internal/click/fail_cost

# dispatch by kind (act files must NOT call _resolve again)
data modify storage guikit:work kind set from storage guikit:act w.kind
function guikit:internal/click/dispatch_kind with storage guikit:work

execute if data storage guikit:act w.cooldown_ticks run function guikit:internal/click/cd_arm
execute if data storage guikit:act w.success_message.text run function guikit:act/_success_msg

scoreboard players set @s guikit.click 2
