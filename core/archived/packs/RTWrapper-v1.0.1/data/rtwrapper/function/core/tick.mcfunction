# Disabled by default. Enable with: function rtwrapper:api/autotick/on
# Autotick intentionally processes only one action per tick. Use rtwrapper:api/run
# when you explicitly want to drain the whole queue immediately.
execute unless score #rtwrapper.gate.2 vortaforge.gate matches 0 unless score #rtwrapper.permit vortaforge.gate matches 1 run function rtwrapper:gate/permit_tick
execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute unless score #rtwrapper.gate.3 vortaforge.gate matches 0 as @a[tag=!rtwrapper.consented] run function rtwrapper:gate/consent_tick
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
execute if score #auto_tick rtw.config matches 1.. run function rtwrapper:core/run/run_next
