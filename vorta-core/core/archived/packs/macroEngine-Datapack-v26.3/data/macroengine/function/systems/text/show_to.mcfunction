# ─────────────────────────────────────────────────────────────────
# macroengine:systems/text/show_to [MACRO]
# As systems/text/show, but to an arbitrary selector.
#
# INPUT: $(storage), $(path), $(target)
#
# Usage:  function macroengine:systems/text/show_to {storage:"macroengine:engine",path:"flags",target:"@a[tag=macroengine.admin]"}
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{text:0b} run return 0
$tellraw $(target) [{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"storage":"$(storage)","nbt":"$(path)","plain":true,"interpret":false,"color":"white"}]
