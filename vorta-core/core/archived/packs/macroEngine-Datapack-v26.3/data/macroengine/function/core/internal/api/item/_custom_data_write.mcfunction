# macroengine:core/internal/api/item/_custom_data_write [MACRO]
# Internal - writes custom_data once item_id / item_count are known.
# 26.3 notes: `item modify entity ... {inline JSON}` is silently ignored, and
# `data modify entity <player> Inventory[..].components...` fails with
# "Unable to modify player data". The only working path is rewriting the stack
# with the component attached, keeping id and count.

$execute if data storage macroengine:_item_tmp {slot_src:"inventory"} if data storage macroengine:_item_tmp item_id run item replace entity @a[name=$(player),limit=1] $(slot) with $(item_id)[minecraft:custom_data={macroengine:$(macroengine)}] $(item_count)
$execute if data storage macroengine:_item_tmp {slot_src:"equipment"} if data storage macroengine:_item_tmp item_id run item replace entity @a[name=$(player),limit=1] $(eq_slot) with $(item_id)[minecraft:custom_data={macroengine:$(macroengine)}] $(item_count)
$execute if data storage macroengine:_item_tmp {slot_src:"selected"} if data storage macroengine:_item_tmp item_id run item replace entity @a[name=$(player),limit=1] weapon.mainhand with $(item_id)[minecraft:custom_data={macroengine:$(macroengine)}] $(item_count)
