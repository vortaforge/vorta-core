# macroengine:systems/rate_limit/player/internal/ensure — Seed player bucket from template [MACRO]
# Input: $(tpl), $(full)
# Called only when bucket doesn't exist yet for this player.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$execute unless data storage macroengine:engine rate_limit.player_templates.$(tpl) run return 0
$data modify storage macroengine:engine "rate_limit.rules.$(full)" set from storage macroengine:engine rate_limit.player_templates.$(tpl)
$data modify storage macroengine:engine "rate_limit.rules.$(full).hits" set value []
