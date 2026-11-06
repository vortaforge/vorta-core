# Storage removal: applies immediately — no permission check. This command
# can destroy arbitrary storage data (including macroengine's own engine
# state) — callers should be careful with $(path).
#
# INPUT : $(storage) -> storage id, e.g. "macroengine:engine"
#         $(path)    -> NBT path to remove, e.g. "some_field"
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{cmd:0b} run return 0
$function macroengine:core/internal/cmd/data_remove_storage_apply {storage:"$(storage)",path:"$(path)"}
