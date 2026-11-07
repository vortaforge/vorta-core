# macroengine:systems/rate_limit/internal/no_rule — Warn when check called on unregistered key [MACRO]
# Input: $(key)
# Fail-open: result stays 1b (ALLOWED) so callers aren't broken by missing config.
execute if data storage macroengine:engine modules{rate_limit:0b} run return 0

$tellraw @a[tag=macroengine.admin] [{"text":"[MACROENGINE/WARNING] ","color":"gold","bold":true},{"text":"Rate limit check called for unregistered key: ","color":"yellow"},{"text":"$(key)","color":"red","bold":true},{"text":". Falling back to default (ALLOWED).","color":"gray"}]