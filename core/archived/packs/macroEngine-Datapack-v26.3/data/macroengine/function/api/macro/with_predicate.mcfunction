# ─────────────────────────────────────────────
# macroengine:api/macro/with_advancement [MACRO]
#

# Clear pipe
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{macro:0b} run return 0
data remove storage macroengine:engine _macro_pipe

# Default: not completed
$data modify storage macroengine:engine _macro_pipe.$(var) set value "empty"

# Set to 1b if the player has completed the tag
$execute as @a[name=$(player),limit=1] if predicate $(condition) run data modify storage macroengine:engine _macro_pipe.$(var) set value 1b
$execute as @a[name=$(player),limit=1] unless predicate $(condition) run data modify storage macroengine:engine _macro_pipe.$(var) set value 0b

# Call target function with pipe as macro source
$function $(func) with storage macroengine:engine _macro_pipe