# Macro: called with storage rtwrapper:api trigger (fields: objective, action, reset_mode).
# Creates the trigger-type scoreboard objective and appends the registration entry.
execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
$scoreboard objectives add $(objective) trigger
$data modify storage rtwrapper:triggers registry append value {objective:"$(objective)",enabled:1b,reset_mode:"$(reset_mode)",action:$(action)}
$scoreboard players enable @s $(objective)
