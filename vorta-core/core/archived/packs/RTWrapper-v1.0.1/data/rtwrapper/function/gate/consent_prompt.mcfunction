# Gate 3 - shown once per player until they consent.
tag @s add rtwrapper.prompted
tellraw @s [{"text":"[rtwrapper] This datapack stays inactive for you until you agree to it. ","color":"yellow"},{"text":"[Agree]","color":"green","click_event":{"action":"run_command","command":"/trigger rtwrapper.consent set 1"}},{"text":" or type /trigger rtwrapper.consent set 1","color":"gray"}]
