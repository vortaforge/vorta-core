# Macro dispatch. `cmd` must match an internal wrapper dispatcher file name.
execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
# Dispatch is off by default (score #dynamic, rtw.config): rtwrapper:api/dynamic/on enables it.
execute unless score #dynamic rtw.config matches 1 run return 0
$function rtwrapper:core/wrappers/internal/$(cmd)
