# Gate 3 - run as the player who answered "no" on the confirm screen.
# Consent is not recorded; the datapack stays inactive for this player. "prompted" stays set so the
# screen is not forced open again every tick. The player can reopen it with /trigger macroengine.consent set 1
scoreboard players reset @s macroengine.dlg_no
tellraw @s [{"text":"[macroengine] Cancelled. This datapack stays inactive for you. ","color":"yellow"},{"text":"[Open consent screen]","color":"green","click_event":{"action":"run_command","command":"/trigger macroengine.consent set 1"}}]
