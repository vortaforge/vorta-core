# Gate 2 - permission via /trigger. Runs from the tick entry only while the pack is not approved.
# /trigger works without cheats, allowCommands or /op, so nobody has to enable those for this.
# A trigger is not authenticated: on a server with untrusted players any player can approve.
# Servers that need real access control should call rtwrapper:gate/set/2_on and approve through a function (operator) instead.
scoreboard players enable @a rtwrapper.permit
execute as @a[scores={rtwrapper.permit=1}] run function rtwrapper:gate/permit_grant
execute as @a[scores={rtwrapper.permit=2..}] run scoreboard players reset @s rtwrapper.permit
