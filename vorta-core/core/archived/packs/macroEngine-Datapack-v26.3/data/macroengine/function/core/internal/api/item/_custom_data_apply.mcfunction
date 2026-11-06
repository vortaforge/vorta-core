# macroengine:core/internal/api/item/_custom_data_apply [MACRO]
# Internal - called AFTER _slot_map. Reads the target item's id/count and hands
# the write off to _custom_data_write (macro arguments are bound at call time,
# so a value produced in one function cannot be used as $(...) in the same one).
# Input (macroengine:_item_tmp): player, slot (as given by the caller),
#                                slot_src, slot_n, macroengine (compound to write)

$execute if data storage macroengine:_item_tmp {slot_src:"inventory"} unless data storage macroengine:_item_tmp {slot_n:-1} run data modify storage macroengine:_item_tmp item_id set from entity @a[name=$(player),limit=1] Inventory[{Slot:$(slot_n)b}].id
$execute if data storage macroengine:_item_tmp {slot_src:"inventory"} unless data storage macroengine:_item_tmp {slot_n:-1} run data modify storage macroengine:_item_tmp item_count set from entity @a[name=$(player),limit=1] Inventory[{Slot:$(slot_n)b}].count
$execute if data storage macroengine:_item_tmp {slot_src:"equipment"} run data modify storage macroengine:_item_tmp item_id set from entity @a[name=$(player),limit=1] equipment.$(eq_key).id
$execute if data storage macroengine:_item_tmp {slot_src:"equipment"} run data modify storage macroengine:_item_tmp item_count set from entity @a[name=$(player),limit=1] equipment.$(eq_key).count
$execute if data storage macroengine:_item_tmp {slot_src:"selected"} run data modify storage macroengine:_item_tmp item_id set from entity @a[name=$(player),limit=1] SelectedItem.id
$execute if data storage macroengine:_item_tmp {slot_src:"selected"} run data modify storage macroengine:_item_tmp item_count set from entity @a[name=$(player),limit=1] SelectedItem.count
function macroengine:core/internal/api/item/_custom_data_write with storage macroengine:_item_tmp
