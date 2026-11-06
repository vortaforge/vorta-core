# macroengine:core/internal/api/perm/group/_add_one [INTERNAL - macro]
# INPUT: $(value) - a permission name that passed safe_name in _apply_loop.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$execute as @a if score @s macroengine.pid = $grp_pid macroengine.tmp run tag @s add perm.$(value)
