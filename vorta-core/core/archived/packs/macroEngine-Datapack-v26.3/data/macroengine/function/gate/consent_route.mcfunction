# Gate 2 -> Gate 3 hand-off. Called right after the pack is approved (permit_grant, approve).
#
# The consent screen is per player. It must open for the player who approved (or for the target of
# "execute as <player> run function macroengine:gate/approve"), not for everybody online at the
# same moment. Everyone else gets a one-line chat notice with a click action instead, and the
# screen still opens by itself for players who join later (gate/consent_prompt).
#
# Runs as: the approving entity. A player gets the screen. A non-player (console, command block,
# schedule) gets nothing, so every online player is only told in chat.

# Whoever approves is handled directly, so the tick must not force the screen open for them again
execute if entity @s[type=minecraft:player,tag=!macroengine.consented] run tag @s add macroengine.prompted

# Everyone else who has not consented: chat notice only, and no forced screen
tellraw @a[tag=!macroengine.consented,tag=!macroengine.prompted] [{"text":"[macroengine] The datapack is now approved, but it stays inactive for you until you confirm the notice. ","color":"yellow"},{"text":"[Open consent screen]","color":"green","click_event":{"action":"run_command","command":"/trigger macroengine.consent set 1"}}]
tag @a[tag=!macroengine.consented,tag=!macroengine.prompted] add macroengine.prompted

# The approver sees the screen
execute if entity @s[type=minecraft:player,tag=!macroengine.consented] run function macroengine:gate/consent_dialog
