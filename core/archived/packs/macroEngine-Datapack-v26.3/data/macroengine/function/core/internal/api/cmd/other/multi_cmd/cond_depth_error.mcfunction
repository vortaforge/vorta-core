# ─────────────────────────────────────────────────────────────────
# macroengine:core/internal/api/cmd/other/multi_cmd/cond_depth_error
# Condition nesting deeper than MAX_DEPTH. Fails closed: the condition
# reports 0 (not passed) so an over-deep tree can never silently pass.
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set $mcmd_cond_result macroengine.tmp 0

tellraw @a[tag=macroengine.admin] ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"condition nesting exceeds the depth limit; treating it as not passed","color":"red"}]
