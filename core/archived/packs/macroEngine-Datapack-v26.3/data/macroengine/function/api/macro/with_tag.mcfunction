# ─────────────────────────────────────────────
# macroengine:api/macro/with_advancement [MACRO]
#

# Clear pipe
execute if data storage macroengine:engine modules{macro:0b} run return 0
data remove storage macroengine:engine _macro_pipe

# Default: not completed
$data modify storage macroengine:engine _macro_pipe.$(var) set value "empty"

# Set to 1b if the player has completed the tag
$execute as @a[name=$(player),limit=1,tag=$(tag)] run data modify storage macroengine:engine _macro_pipe.$(var) set value 1b
$execute as @a[name=$(player),limit=1,tag=!$(tag)] run data modify storage macroengine:engine _macro_pipe.$(var) set value 0b

# Call target function with pipe as macro source
$function $(func) with storage macroengine:engine _macro_pipe