# macroengine:core/internal/api/cmd/other/multi_cmd/cond_storage_exec [MACRO]
# INPUT: $(storage)

$execute unless data storage $(storage) run scoreboard players set $mcmd_cond_result macroengine.tmp 0
