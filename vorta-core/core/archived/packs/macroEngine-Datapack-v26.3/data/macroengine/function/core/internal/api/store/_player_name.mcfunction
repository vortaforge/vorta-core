# macroengine:core/internal/api/store/_player_name [INTERNAL]
# Executor name as a plain string in tmp.val; tmp.val stays unset when the executor is not a player.
# Minecraft only exposes a player's name through text component resolution, so a short-lived
# text_display resolves a selector that points at the executor (via a tag, because @s inside the
# display would be the display itself). The result is read back and reduced to a string at once;
# the component is never kept. A bare string, {text:"..."} and the team form (name in extra[1]) are handled.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless entity @s[type=player] run return 0
tag @s add macroengine.pn_subject
summon text_display ~ ~ ~ {Tags:["macroengine.pn_display"]}
data modify entity @e[type=text_display,tag=macroengine.pn_display,limit=1] text set value {selector:"@a[tag=macroengine.pn_subject,limit=1]"}
data modify storage macroengine:store tmp.pn set from entity @e[type=text_display,tag=macroengine.pn_display,limit=1] text
kill @e[type=text_display,tag=macroengine.pn_display]
tag @s remove macroengine.pn_subject
execute unless data storage macroengine:store tmp.pn{} unless data storage macroengine:store tmp.pn[] run data modify storage macroengine:store tmp.val set from storage macroengine:store tmp.pn
execute if data storage macroengine:store tmp.pn{} unless data storage macroengine:store tmp.pn{text:""} run data modify storage macroengine:store tmp.val set from storage macroengine:store tmp.pn.text
execute if data storage macroengine:store tmp.pn{text:""} run data modify storage macroengine:store tmp.val set from storage macroengine:store tmp.pn.extra[1].text
data remove storage macroengine:store tmp.pn
