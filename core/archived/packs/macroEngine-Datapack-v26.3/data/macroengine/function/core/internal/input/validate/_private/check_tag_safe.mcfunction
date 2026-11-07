# ======================================================================================
# macroengine:core/internal/input/validate/_private/check_tag_safe  [INTERNAL]
# ======================================================================================
# Rejects empty strings and any string containing one of: space " ' { } [ ] : § | ^ < >
# or a literal backslash. A safe result can be used as a scoreboard objective/player-name
# fragment or dropped unquoted into a single NBT string field without escaping.
#
# Double quote and backslash are caught first by core/internal/text/safe; the remaining
# characters come from the deny_tag table via core/internal/text/scan_deny, which looks at
# one character at a time and never substitutes the input as a whole into a command.
# ======================================================================================
execute store result score #macroengine.Len macroengine.tmp run data get storage macroengine:input_validate scratch.value
execute if score #macroengine.Len macroengine.tmp matches 0 run data modify storage macroengine:input_validate result.error set value "empty input"
execute if score #macroengine.Len macroengine.tmp matches 0 run return 0
data modify storage macroengine:text s set from storage macroengine:input_validate scratch.value
data modify storage macroengine:input_validate scratch.bad set value 0b
execute store result score #macroengine.TagSafe macroengine.tmp run function macroengine:core/internal/text/safe
execute if score #macroengine.TagSafe macroengine.tmp matches 0 run data modify storage macroengine:input_validate scratch.bad set value 1b
data modify storage macroengine:text tbl set value "deny_tag"
execute if score #macroengine.TagSafe macroengine.tmp matches 1 store result score #macroengine.TagHit macroengine.tmp run function macroengine:core/internal/text/scan_deny
execute if score #macroengine.TagSafe macroengine.tmp matches 1 if score #macroengine.TagHit macroengine.tmp matches 1 run data modify storage macroengine:input_validate scratch.bad set value 1b
data remove storage macroengine:text tbl
function macroengine:core/internal/text/reset
execute unless data storage macroengine:input_validate {scratch:{bad:1b}} run data modify storage macroengine:input_validate result.valid set value 1b
execute if data storage macroengine:input_validate {scratch:{bad:1b}} run data modify storage macroengine:input_validate result.error set value "contains a disallowed character (space, quote, brace, bracket, colon, or backslash)"
data remove storage macroengine:input_validate scratch.bad
