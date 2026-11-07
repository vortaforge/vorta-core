# macroengine:core/internal/text/count
# INPUT macroengine:text: s, needle.  RETURN number of non-overlapping occurrences.
data modify storage macroengine:text n set value 0
return run function macroengine:core/internal/text/find
