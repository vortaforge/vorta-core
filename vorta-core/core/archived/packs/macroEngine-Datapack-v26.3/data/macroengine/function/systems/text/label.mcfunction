# ─────────────────────────────────────────────────────────────────
# macroengine:systems/text/label [MACRO]
# Prints "label: value" for one NBT value, so list-style output does not
# have to hand-build the same component every time.
#
# INPUT: $(label), $(storage), $(path)
#
# Usage:  function macroengine:systems/text/label {label:"flags",storage:"macroengine:engine",path:"flags"}
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{text:0b} run return 0
$tellraw @s [{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"$(label)","color":"gray"},{"text":": ","color":"#555555"},{"storage":"$(storage)","nbt":"$(path)","plain":true,"interpret":false,"color":"white"}]
