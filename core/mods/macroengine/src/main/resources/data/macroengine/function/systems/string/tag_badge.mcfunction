# ─────────────────────────────────────────────────────────────────
# macroengine:systems/string/tag_badge
# Sends a styled [TAG] badge with optional hover text.
#  Input : $(target)     → selector
#          $(tag)        → badge label (e.g. "ADMIN", "VIP")
#          $(color)      → badge color (e.g. "red", "gold")
#          $(hover)      → hover tooltip text
#
# Example:
# data modify storage macroengine:input target set value "@s"
# data modify storage macroengine:input tag set value "ADMIN"
# data modify storage macroengine:input color set value "red"
# data modify storage macroengine:input hover set value "Server Administrator"
# function macroengine:systems/string/tag_badge with storage macroengine:input {}
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{string:0b} run return 0
$tellraw $(target) ["",{"text":"[","color":"#555555","bold":false},{"text":"$(tag)","color":"$(color)","bold":true,"hover_event":{"action":"show_text","value":{"text":"$(hover)","color":"gray","italic":true}}},{"text":"]","color":"#555555","bold":false}]
