# macroengine:api/title/show_to_p [MACRO]
# show_p for a named player. Input (macro arg): player. Storage input as show_p.
execute if data storage macroengine:engine modules{title:0b} run return 0
$execute as @a[name=$(player),limit=1] run function macroengine:api/title/show_p
