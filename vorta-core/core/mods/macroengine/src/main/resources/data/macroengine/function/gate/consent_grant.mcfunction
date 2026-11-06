# Gate 3 - run as the player who typed /trigger macroengine.consent set 1.
tag @s add macroengine.consented
tag @s remove macroengine.prompted
scoreboard players reset @s macroengine.consent
tellraw @s {"text":"[macroengine] Consent recorded. An operator can withdraw it with /function macroengine:gate/consent_reset","color":"green"}
