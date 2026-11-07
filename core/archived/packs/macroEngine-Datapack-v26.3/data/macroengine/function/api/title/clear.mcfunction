# macroengine:api/title/clear [MACRO]
# Clears the title currently shown to a player. Input (macro arg): player
execute if data storage macroengine:engine modules{title:0b} run return 0
$title @a[name=$(player),limit=1] clear
