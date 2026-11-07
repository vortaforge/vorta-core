# ─────────────────────────────────────────────────────────────────
# macroengine:systems/text/show [MACRO]
# Prints one NBT value to the caller, rendered as plain text.
#
# INPUT: $(storage) — storage namespace, e.g. "macroengine:engine"
#        $(path)    — NBT path inside it, e.g. "flags"
#
# Both `plain` and `interpret` are set explicitly, and that is the whole
# point of this helper. On 26.1+ a component that reads NBT renders:
#
#   {"storage":...,"nbt":...}                            "Example Text"
#   {...,"interpret":true}                                Example Text
#   {...,"interpret":false,"plain":true}                  Example Text
#
# The first form keeps the quotes, which is almost never what a caller
# wants. `plain` also strips vanilla's colouring and type suffix from
# numbers and booleans, so a stored 1b prints as 1 rather than a coloured
# 1b. Leaving either key out is what makes output depend on the stored
# value's type.
#
# Usage:  function macroengine:systems/text/show {storage:"macroengine:engine",path:"flags"}
# ─────────────────────────────────────────────────────────────────

execute if data storage macroengine:engine modules{text:0b} run return 0
$tellraw @s [{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"storage":"$(storage)","nbt":"$(path)","plain":true,"interpret":false,"color":"white"}]
