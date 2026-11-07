# macroengine:core/internal/text/scan_deny
# INPUT  macroengine:text: s, tbl (name of a table in macroengine:text_map)
# RETURN 1 if any character of s is a key of that table, else 0.
# s must not contain a quote or backslash (check with safe first).
execute store result score #tx_len macroengine.tmp run data get storage macroengine:text s
scoreboard players set #tx_i macroengine.tmp 0
scoreboard players set #tx_hit macroengine.tmp 0
execute if score #tx_len macroengine.tmp matches 1.. run function macroengine:core/internal/text/scan_deny_loop
return run scoreboard players get #tx_hit macroengine.tmp
