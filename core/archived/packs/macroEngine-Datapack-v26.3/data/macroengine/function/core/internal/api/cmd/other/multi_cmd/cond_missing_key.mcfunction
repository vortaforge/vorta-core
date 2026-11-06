# ─────────────────────────────────────────────────────────────────
# macroengine:core/internal/api/cmd/other/multi_cmd/cond_missing_key
# A required condition key was absent. Macro expansion of the checker
# would fail silently and leave the verdict at its default (passed),
# so fail closed and say why.
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set $mcmd_cond_result macroengine.tmp 0

tellraw @a[tag=macroengine.admin] ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"condition is missing a required key; treating it as not passed","color":"red"}]
