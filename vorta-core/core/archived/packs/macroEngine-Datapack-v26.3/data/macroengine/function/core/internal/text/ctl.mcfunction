# macroengine:core/internal/text/ctl
# RETURN 1 when macroengine:text s contains a newline, a carriage return or a tab, else 0.
# Such characters cannot be substituted into a macro line, so validators reject them.
# Static comparisons only, no macros. Touches only cf, sc, sq.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:text cf set from storage macroengine:text s
execute store result score #tx_sn macroengine.tmp run data get storage macroengine:text cf
execute if score #tx_sn macroengine.tmp matches 0 run return 0
return run function macroengine:core/internal/text/ctl_loop
