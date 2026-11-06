# Gate 3 - per-player consent via /trigger. Runs as a player who has not consented yet,
# called from the tick entry. No cheats, allowCommands or /op needed.
scoreboard players enable @s rtwrapper.consent
execute if score @s rtwrapper.consent matches 1 run function rtwrapper:gate/consent_grant
execute if score @s rtwrapper.consent matches 2.. run scoreboard players reset @s rtwrapper.consent
execute if entity @s[tag=!rtwrapper.consented,tag=!rtwrapper.prompted] run function rtwrapper:gate/consent_prompt
