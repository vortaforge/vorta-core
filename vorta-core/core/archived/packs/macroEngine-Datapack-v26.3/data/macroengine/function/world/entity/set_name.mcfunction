# ─────────────────────────────────────────────────────────────────
# macroengine:world/entity/set_name
# Sets the display name (CustomName) on every entity matching the
# given tag. The name is read from macroengine:input name — NOT passed
# as a macro argument — to avoid quote/apostrophe injection crashes
# and to support full JSON text components on all versions.
#
# INPUT : $(tag)              → entity tag to match
#         macroengine:input name  → JSON text component (caller sets this
#                               before calling this function)
#
# CALLER PATTERN:
#   # Plain white text (works on all versions):
#   data modify storage macroengine:input name set value '"Dragon King"'
#
#   # Colored component (works on all versions):
#   data modify storage macroengine:input name set value '{"text":"Dragon King","color":"red"}'
#
#   function macroengine:world/entity/set_name {tag:"myboss"}
#
# NOTE: data modify storage → CustomName works on all supported
#       versions without version-specific syntax differences.
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$execute as @e[tag=$(tag)] run data modify entity @s CustomName set from storage macroengine:input name
