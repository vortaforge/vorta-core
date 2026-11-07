# macroengine:api/title/actionbar_tag_p [MACRO]
# actionbar_p for every online player carrying a tag. Input (macro arg): tag. Storage input as actionbar_p.
execute if data storage macroengine:engine modules{title:0b} run return 0
$execute as @a[tag=$(tag)] run function macroengine:api/title/actionbar_p
