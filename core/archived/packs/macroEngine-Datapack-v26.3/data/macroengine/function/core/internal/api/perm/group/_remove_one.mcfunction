# macroengine:core/internal/api/perm/group/_remove_one [INTERNAL - macro]
# INPUT: $(value) - a permission name that passed safe_name in _apply_loop.

$execute as @a if score @s macroengine.pid = $grp_pid macroengine.tmp run tag @s remove perm.$(value)
