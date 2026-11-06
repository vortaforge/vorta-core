# ─────────────────────────────────────────────────────────────────
# macroengine:systems/string/score_display
# Sends a formatted label: value line from a scoreboard objective.
#  Input : $(target)    → selector to receive the message
#          $(label)     → display label (e.g. "Points")
#          $(player)    → scoreboard player name (e.g. "@s", "<player name>")
#          $(objective) → scoreboard objective name
#          $(color)     → value color (e.g. "green", "gold")
#
# Example:
# data modify storage macroengine:input target set value "@s"
# data modify storage macroengine:input label set value "Points"
# data modify storage macroengine:input player set value "@s"
# data modify storage macroengine:input objective set value "myPoints"
# data modify storage macroengine:input color set value "green"
# function macroengine:systems/string/score_display with storage macroengine:input {}
# Output: "Points 42" (42 from scoreboard)
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{string:0b} run return 0
$tellraw $(target) ["",{"text":"$(label)","color":"gray"},{"text":"  ","color":"#555555"},{"score":{"name":"$(player)","objective":"$(objective)"},"color":"$(color)","bold":true}]
