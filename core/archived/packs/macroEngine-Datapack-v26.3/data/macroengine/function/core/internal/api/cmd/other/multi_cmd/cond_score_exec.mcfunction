# macroengine:core/internal/api/cmd/other/multi_cmd/cond_score_exec [MACRO]
# INPUT: $(objective), $(min), $(max), $(target)
#
# `store success` distinguishes "score is 0" from "no score at all":
# without it a missing score would read as 0 and silently satisfy a
# min:..0 range.

$execute store success score $mcmd_cond_ok macroengine.tmp if score $(target) $(objective) matches -2147483648..2147483647
execute if score $mcmd_cond_ok macroengine.tmp matches 0 run scoreboard players set $mcmd_cond_result macroengine.tmp 0
$execute if score $mcmd_cond_ok macroengine.tmp matches 1 store result score $mcmd_cond_score macroengine.tmp run scoreboard players get $(target) $(objective)
$execute if score $mcmd_cond_ok macroengine.tmp matches 1 if score $mcmd_cond_score macroengine.tmp matches $(min)..$(max) run scoreboard players set $mcmd_cond_result macroengine.tmp 1
$execute if score $mcmd_cond_ok macroengine.tmp matches 1 unless score $mcmd_cond_score macroengine.tmp matches $(min)..$(max) run scoreboard players set $mcmd_cond_result macroengine.tmp 0
