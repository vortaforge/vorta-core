# macroengine:core/internal/text/has
# INPUT macroengine:text: s, needle.  RETURN 1 if s contains needle, else 0.
data modify storage macroengine:text n set value 1
return run function macroengine:core/internal/text/find
