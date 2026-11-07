# macroengine:core/internal/api/store/_tok_score_build [MACRO] [INTERNAL]
# $(obj) was checked with safe_name: no quote, backslash, brace, bracket or whitespace.
# Reads the score with the scoreboard itself, so no text component is involved. The range
# test makes the line do nothing when the executor has no score on the objective.
$execute if score @s $(obj) matches -2147483648..2147483647 store result storage macroengine:store tmp.num int 1 run scoreboard players get @s $(obj)
