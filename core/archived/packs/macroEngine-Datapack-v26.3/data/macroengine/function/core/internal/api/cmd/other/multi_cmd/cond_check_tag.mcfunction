# ─────────────────────────────────────────────────────────────────
# macroengine:core/internal/api/cmd/other/multi_cmd/cond_check_tag
# Tag leaf. Two accepted shapes:
#   condition.tag = "admin"                  shorthand for {name:"admin",has:1b}
#   condition.tag = {name:"admin",has:1b|0b} has:0b asserts the tag is ABSENT
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:engine _mcmd_cond_eval.tag{} run function macroengine:core/internal/api/cmd/other/multi_cmd/cond_tag_simple
execute if data storage macroengine:engine _mcmd_cond_eval.tag{} run function macroengine:core/internal/api/cmd/other/multi_cmd/cond_tag_object
