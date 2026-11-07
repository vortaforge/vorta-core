# macroengine:core/internal/text/safe
# RETURN 1 when macroengine:text s contains neither a double quote nor a backslash, else 0.
# Anything that is rebuilt into a macro string literal must pass this first.
# Walks the string one character at a time without macros; touches only sf, sc, sq.
data modify storage macroengine:text sf set from storage macroengine:text s
execute store result score #tx_sn macroengine.tmp run data get storage macroengine:text sf
execute if score #tx_sn macroengine.tmp matches 0 run return 1
return run function macroengine:core/internal/text/safe_loop
