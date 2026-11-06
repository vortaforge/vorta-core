# Gate 3 - per-player consent via /trigger. Runs as a player who has not consented yet,
# called from the tick entry. No cheats, allowCommands or /op needed.
#   /trigger macroengine.consent set 1   opens the notice dialog (it no longer grants consent by itself)
#   macroengine.dlg_yes / macroengine.dlg_no   are fired by the confirm dialog's Submit button ("yes" / "no")
# A trigger is not authenticated: a player can also type /trigger macroengine.dlg_yes set 1 in chat and skip the
# dialog. The dialog makes the notice hard to miss; it does not enforce reading it.
scoreboard players enable @s macroengine.consent
scoreboard players enable @s macroengine.dlg_yes
scoreboard players enable @s macroengine.dlg_no
execute if score @s macroengine.dlg_yes matches 1 run function macroengine:gate/consent_grant
execute if entity @s[tag=!macroengine.consented] if score @s macroengine.dlg_no matches 1 run function macroengine:gate/consent_decline
execute if entity @s[tag=!macroengine.consented] if score @s macroengine.consent matches 1 run function macroengine:gate/consent_dialog

# Reset a trigger only after it was used (value other than 0). Resetting an unused one removes its score,
# which leaves it disabled between ticks, and /trigger then fails with "You cannot trigger this objective yet".
execute unless score @s macroengine.consent matches 0 run scoreboard players reset @s macroengine.consent
execute unless score @s macroengine.dlg_yes matches 0 run scoreboard players reset @s macroengine.dlg_yes
execute unless score @s macroengine.dlg_no matches 0 run scoreboard players reset @s macroengine.dlg_no

execute if entity @s[tag=!macroengine.consented,tag=!macroengine.prompted] run function macroengine:gate/consent_prompt
