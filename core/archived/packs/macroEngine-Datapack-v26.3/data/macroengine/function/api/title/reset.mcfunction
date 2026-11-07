# macroengine:api/title/reset [MACRO]
# Clears the title and resets fade/stay times to vanilla defaults. Input (macro arg): player
execute if data storage macroengine:engine modules{title:0b} run return 0
$title @a[name=$(player),limit=1] reset
