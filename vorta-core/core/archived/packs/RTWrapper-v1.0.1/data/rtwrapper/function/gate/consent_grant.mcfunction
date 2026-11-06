# Gate 3 - run as the player who typed /trigger rtwrapper.consent set 1.
tag @s add rtwrapper.consented
tag @s remove rtwrapper.prompted
scoreboard players reset @s rtwrapper.consent
tellraw @s {"text":"[rtwrapper] Consent recorded. An operator can withdraw it with /function rtwrapper:gate/consent_reset","color":"green"}
