# macroengine:core/internal/api/store/_all_one [INTERNAL]
# Runs as one player: renders the current in.* and appends {uuid, string} to all.entries.
execute unless function macroengine:api/store/render run return 0
data modify storage macroengine:store all.entries append value {}
data modify storage macroengine:store all.entries[-1].uuid set from entity @s UUID
data modify storage macroengine:store all.entries[-1].string set from storage macroengine:store out.string
