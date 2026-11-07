# macroengine:api/title/broadcast_p
# show_p for every online player; %player% and %score:...% resolve per recipient.
# Storage input as show_p.
execute if data storage macroengine:engine modules{title:0b} run return 0
execute as @a run function macroengine:api/title/show_p
