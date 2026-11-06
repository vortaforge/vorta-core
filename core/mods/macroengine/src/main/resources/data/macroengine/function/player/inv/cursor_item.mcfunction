# Detect click (slot empty after interaction)
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$execute as @a[name=$(player),limit=1] at @s if items entity @s player.cursor $(item)[minecraft:custom_data=$(data)] run $(invoke)
