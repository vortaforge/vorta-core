# Gate 3 - opens the consent screens for the player it runs as.
# Screen 1 (macroengine:gate/warning): third-party content + prompt-injection notice, link to INFO.md.
# Screen 2 (macroengine:gate/confirm): text box + Submit. Submit runs, as the player:
#   /trigger macroengine.dlg_<answer> set 1
# so only "yes" (macroengine.dlg_yes) and "no" (macroengine.dlg_no) match an objective. Anything else is a
# command error and changes nothing. A trigger is used (not /function) because /function needs
# operator permission and gate 3 must work without cheats, allowCommands or /op.
# The text box value is only ever placed in the objective-name slot of that one command.
dialog show @s macroengine:gate/warning
tellraw @s [{"text":"[macroengine] If the screen closed, reopen it: ","color":"gray"},{"text":"[Open consent screen]","color":"yellow","click_event":{"action":"run_command","command":"/trigger macroengine.consent set 1"}}]
