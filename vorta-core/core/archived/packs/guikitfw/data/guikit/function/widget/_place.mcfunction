# action_id || id || kind_slot (guigen resolvedActionId)
execute unless data storage guikit:draw w.id if data storage guikit:draw w.action_id run data modify storage guikit:draw w.id set from storage guikit:draw w.action_id
execute unless data storage guikit:draw w.id run data modify storage guikit:draw w.id set from storage guikit:draw w.kind
execute unless data storage guikit:draw w.kind run data modify storage guikit:draw w.kind set value "button"
execute unless data storage guikit:draw w.item run data modify storage guikit:draw w.item set value "minecraft:stone"

data modify storage guikit:work slot set from storage guikit:draw w.slot
data modify storage guikit:work item set from storage guikit:draw w.item
data modify storage guikit:work id set from storage guikit:draw w.id
data modify storage guikit:work type set from storage guikit:draw w.kind
data modify storage guikit:work menu set from storage guikit:ctx menu
execute unless data storage guikit:work menu run data modify storage guikit:work menu set value "_"
function guikit:widget/_place_do with storage guikit:work

# optional name via item modify path — static name applied if present
execute if data storage guikit:draw w.name run function guikit:internal/text/apply_name

# Non-interactive (guigen NON_INTERACTIVE_KINDS)
execute if data storage guikit:draw w{kind:"separator"} run return 0
execute if data storage guikit:draw w{kind:"label"} run return 0
execute if data storage guikit:draw w{kind:"indicator"} run return 0
execute if data storage guikit:draw w{kind:"progress"} run return 0
execute if data storage guikit:draw w{clickable:0b} run return 0
data modify storage guikit:ctx actions append from storage guikit:draw w
