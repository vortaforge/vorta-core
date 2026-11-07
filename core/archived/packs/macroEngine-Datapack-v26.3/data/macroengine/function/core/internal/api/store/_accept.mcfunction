# macroengine:core/internal/api/store/_accept [INTERNAL]
# tmp.raw -> tmp.val when it is a string or a number (what text/concat can join).
# A compound or list value is rejected so render cannot print raw NBT.
execute if data storage macroengine:store tmp.raw{} run return 0
execute if data storage macroengine:store tmp.raw[] run return 0
data modify storage macroengine:store tmp.val set from storage macroengine:store tmp.raw
