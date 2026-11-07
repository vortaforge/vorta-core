# Storage removal: applies immediately — no permission check. This command
# can destroy arbitrary storage data (including macroengine's own engine
# state) — callers should be careful with $(path).
#
# INPUT : $(storage) -> storage id, e.g. "macroengine:engine"
#         $(path)    -> NBT path to remove, e.g. "some_field"
execute if data storage macroengine:engine modules{cmd:0b} run return 0
$function macroengine:core/internal/cmd/data_remove_storage_apply {storage:"$(storage)",path:"$(path)"}
