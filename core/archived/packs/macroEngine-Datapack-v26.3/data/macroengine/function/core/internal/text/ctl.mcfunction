# macroengine:core/internal/text/ctl
# RETURN 1 when macroengine:text s contains a newline, a carriage return or a tab, else 0.
# Such characters cannot be substituted into a macro line, so validators reject them.
# Static comparisons only, no macros. Touches only cf, sc, sq.
data modify storage macroengine:text cf set from storage macroengine:text s
execute store result score #tx_sn macroengine.tmp run data get storage macroengine:text cf
execute if score #tx_sn macroengine.tmp matches 0 run return 0
return run function macroengine:core/internal/text/ctl_loop
