# macroengine:api/title/actionbar — Raw JSON actionbar display [MACRO]
# Displays a full JSON component string in the actionbar of a named player.
# Unlike cmd/actionbar (text + color only), this accepts any serialized component
# including gradients, translate, score, selector, and nbt text sources.
#
# Input (macro args):
#   player — player name selector string (e.g. "Steve")
#   json   — serialized JSON component string
#
# Output → none
#
# Usage:
#   function macroengine:api/title/actionbar {player:"Steve",json:'{"text":"HP: 20/20","color":"red"}'}
#   function macroengine:api/title/actionbar {player:"Steve",\
#     json:'[{"text":"Kills: "},{"score":{"name":"@s","objective":"kills"},"color":"gold"}]'}
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{title:0b} run return 0
$title @a[name=$(player),limit=1] actionbar $(json)
