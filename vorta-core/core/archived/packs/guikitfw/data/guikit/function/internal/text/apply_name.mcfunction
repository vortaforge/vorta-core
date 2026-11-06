# Best-effort: re-place with name if text field exists (simple text only)
data modify storage guikit:work slot set from storage guikit:draw w.slot
data modify storage guikit:work item set from storage guikit:draw w.item
data modify storage guikit:work id set from storage guikit:draw w.id
data modify storage guikit:work type set from storage guikit:draw w.kind
data modify storage guikit:work menu set from storage guikit:ctx menu
data modify storage guikit:work ntext set from storage guikit:draw w.name.text
execute unless data storage guikit:work ntext run return 0
function guikit:internal/text/apply_name_do with storage guikit:work
