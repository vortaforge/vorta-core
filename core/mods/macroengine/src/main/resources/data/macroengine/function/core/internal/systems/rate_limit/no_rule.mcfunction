# macroengine:systems/rate_limit/internal/no_rule — Warn when check called on unregistered key [MACRO]
# Input: $(key)
# Fail-open: result stays 1b (ALLOWED) so callers aren't broken by missing config.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{rate_limit:0b} run return 0

$tellraw @a[tag=macroengine.admin] [{"text":"[MACROENGINE/WARNING] ","color":"gold","bold":true},{"text":"Rate limit check called for unregistered key: ","color":"yellow"},{"text":"$(key)","color":"red","bold":true},{"text":". Falling back to default (ALLOWED).","color":"gray"}]