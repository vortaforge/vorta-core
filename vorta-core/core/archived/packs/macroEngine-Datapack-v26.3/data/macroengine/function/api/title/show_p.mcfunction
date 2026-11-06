# macroengine:api/title/show_p - title + subtitle with %tokens% for @s
#
# Unlike title/show (which builds {"text":"$(title)"} and breaks on quotes or backslashes)
# this reads everything from storage, so any text is safe. Title and subtitle are rendered
# with api/store/render into PLAIN STRINGS (macroengine:title t / s); the text component only
# exists while the title command runs.
#
# INPUT macroengine:title in (all keys optional):
#   title     string with %tokens%   (default: empty)
#   subtitle  string with %tokens%   (default: empty)
#   args      compound for %name% tokens (see api/store/render)
#   fade_in, stay, fade_out   ticks (defaults come from config title_fade_in / title_stay / title_fade_out)
# NOTE: uses macroengine:store in/out while it runs.
#
# Usage:
#   data modify storage macroengine:title in set value {title:"Welcome %player%",subtitle:"Coins: %score:coins%"}
#   function macroengine:api/title/show_p
#   (to address another player:  execute as Steve run function macroengine:api/title/show_p)
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{title:0b} run return 0
execute unless data storage macroengine:title in.fade_in run data modify storage macroengine:title in.fade_in set from storage macroengine:engine config.title_fade_in
execute unless data storage macroengine:title in.fade_in run data modify storage macroengine:title in.fade_in set value 10
execute unless data storage macroengine:title in.stay run data modify storage macroengine:title in.stay set from storage macroengine:engine config.title_stay
execute unless data storage macroengine:title in.stay run data modify storage macroengine:title in.stay set value 70
execute unless data storage macroengine:title in.fade_out run data modify storage macroengine:title in.fade_out set from storage macroengine:engine config.title_fade_out
execute unless data storage macroengine:title in.fade_out run data modify storage macroengine:title in.fade_out set value 20

data remove storage macroengine:store in
data modify storage macroengine:store in.template set value ""
execute if data storage macroengine:title in.title run data modify storage macroengine:store in.template set from storage macroengine:title in.title
execute if data storage macroengine:title in.args run data modify storage macroengine:store in.args set from storage macroengine:title in.args
data modify storage macroengine:title t set value ""
execute if function macroengine:api/store/render run data modify storage macroengine:title t set from storage macroengine:store out.string

data remove storage macroengine:store in
data modify storage macroengine:store in.template set value ""
execute if data storage macroengine:title in.subtitle run data modify storage macroengine:store in.template set from storage macroengine:title in.subtitle
execute if data storage macroengine:title in.args run data modify storage macroengine:store in.args set from storage macroengine:title in.args
data modify storage macroengine:title s set value ""
execute if function macroengine:api/store/render run data modify storage macroengine:title s set from storage macroengine:store out.string

function macroengine:core/internal/api/title/_apply with storage macroengine:title in
