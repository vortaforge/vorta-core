execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{string:0b} run return 0
$scoreboard players set $pb1_seg macroengine.tmp $(current)
$scoreboard players set $pb1_max macroengine.tmp $(max)

execute if score $pb1_max macroengine.tmp matches ..0 run return fail

scoreboard players set $pb1_ten macroengine.tmp 10
scoreboard players operation $pb1_seg macroengine.tmp *= $pb1_ten macroengine.tmp
scoreboard players operation $pb1_seg macroengine.tmp /= $pb1_max macroengine.tmp

execute if score $pb1_seg macroengine.tmp matches ..0 run scoreboard players set $pb1_seg macroengine.tmp 0
execute if score $pb1_seg macroengine.tmp matches 10.. run scoreboard players set $pb1_seg macroengine.tmp 10

$execute if score $pb1_seg macroengine.tmp matches 0 run title @a[name=$(player),limit=1] actionbar {"text":"$(label) ░░░░░░░░░░"}
$execute if score $pb1_seg macroengine.tmp matches 1 run title @a[name=$(player),limit=1] actionbar {"text":"$(label) █░░░░░░░░░"}
$execute if score $pb1_seg macroengine.tmp matches 2 run title @a[name=$(player),limit=1] actionbar {"text":"$(label) ██░░░░░░░░"}
$execute if score $pb1_seg macroengine.tmp matches 3 run title @a[name=$(player),limit=1] actionbar {"text":"$(label) ███░░░░░░░"}
$execute if score $pb1_seg macroengine.tmp matches 4 run title @a[name=$(player),limit=1] actionbar {"text":"$(label) ████░░░░░░"}
$execute if score $pb1_seg macroengine.tmp matches 5 run title @a[name=$(player),limit=1] actionbar {"text":"$(label) █████░░░░░"}
$execute if score $pb1_seg macroengine.tmp matches 6 run title @a[name=$(player),limit=1] actionbar {"text":"$(label) ██████░░░░"}
$execute if score $pb1_seg macroengine.tmp matches 7 run title @a[name=$(player),limit=1] actionbar {"text":"$(label) ███████░░░"}
$execute if score $pb1_seg macroengine.tmp matches 8 run title @a[name=$(player),limit=1] actionbar {"text":"$(label) ████████░░"}
$execute if score $pb1_seg macroengine.tmp matches 9 run title @a[name=$(player),limit=1] actionbar {"text":"$(label) █████████░"}
$execute if score $pb1_seg macroengine.tmp matches 10 run title @a[name=$(player),limit=1] actionbar {"text":"$(label) ██████████"}
