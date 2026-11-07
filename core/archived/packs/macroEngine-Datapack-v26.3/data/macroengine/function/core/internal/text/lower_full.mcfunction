# macroengine:core/internal/text/lower_full
# INPUT  macroengine:text: s    OUTPUT macroengine:text: out   (or err)   RETURN 1 on success, 0 on failure
# Case mapping for the whole BMP (simple one-to-one mappings).
# s must not contain a quote or backslash.
execute unless data storage macroengine:text_map {full:1b} run function macroengine:core/internal/text/load_full
data modify storage macroengine:text tbl set value "lower_full"
return run function macroengine:core/internal/text/case
