# Gate 3 - shown once per player until they consent. Opens the notice + confirmation dialogs
# (macroengine:gate/consent_dialog); the chat line it prints lets the player reopen them.
tag @s add macroengine.prompted
tellraw @s {"text":"[macroengine] This datapack stays inactive for you until you read the notice and confirm it.","color":"yellow"}
function macroengine:gate/consent_dialog
