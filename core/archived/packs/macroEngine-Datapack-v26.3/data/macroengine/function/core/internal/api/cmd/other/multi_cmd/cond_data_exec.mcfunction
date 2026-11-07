# macroengine:core/internal/api/cmd/other/multi_cmd/cond_data_exec [MACRO]
# INPUT: $(storage), $(path), $(min), $(max), $(scale)

$execute store success score $mcmd_cond_ok macroengine.tmp if data storage $(storage) $(path)
execute if score $mcmd_cond_ok macroengine.tmp matches 0 run scoreboard players set $mcmd_cond_result macroengine.tmp 0
$execute if score $mcmd_cond_ok macroengine.tmp matches 1 store result score $mcmd_cond_score macroengine.tmp run data get storage $(storage) $(path) scale $(scale)
$execute if score $mcmd_cond_ok macroengine.tmp matches 1 if score $mcmd_cond_score macroengine.tmp matches $(min)..$(max) run scoreboard players set $mcmd_cond_result macroengine.tmp 1
$execute if score $mcmd_cond_ok macroengine.tmp matches 1 unless score $mcmd_cond_score macroengine.tmp matches $(min)..$(max) run scoreboard players set $mcmd_cond_result macroengine.tmp 0
