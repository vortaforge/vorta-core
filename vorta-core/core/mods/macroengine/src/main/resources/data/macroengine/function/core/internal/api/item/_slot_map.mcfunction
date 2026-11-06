# macroengine:core/internal/api/item/_slot_map [MACRO]
# Internal - resolves an `item modify` style slot name (hotbar.0, inventory.14,
# weapon.mainhand, weapon.offhand, armor.head, ...) into a numeric NBT Slot,
# because 26.3 has no slot-name support in `data modify` paths.
# Writes: slot_src = "inventory" | "selected" | "equipment" (where to read from),
#         slot_n   = numeric inventory slot   (slot_src=inventory)
#         eq_key   = component key            (slot_src=equipment)
#         eq_slot  = slot name for `item replace`

execute if data storage macroengine:_item_tmp {slot:"weapon.mainhand"} run data modify storage macroengine:_item_tmp slot_src set value "selected"
execute if data storage macroengine:_item_tmp {slot:"mainhand"} run data modify storage macroengine:_item_tmp slot_src set value "selected"
# 26.3: worn armor and the offhand are NOT Inventory slots, they live in the
# `equipment` component (equipment.head/chest/legs/feet/offhand).
# eq_key reads from the component, eq_slot is the `item replace` name.
execute if data storage macroengine:_item_tmp {slot:"weapon.offhand"} run data modify storage macroengine:_item_tmp eq_slot set value "weapon.offhand"
execute if data storage macroengine:_item_tmp {slot:"offhand"} run data modify storage macroengine:_item_tmp eq_slot set value "weapon.offhand"
execute if data storage macroengine:_item_tmp {slot:"armor.head"} run data modify storage macroengine:_item_tmp eq_slot set value "armor.head"
execute if data storage macroengine:_item_tmp {slot:"armor.chest"} run data modify storage macroengine:_item_tmp eq_slot set value "armor.chest"
execute if data storage macroengine:_item_tmp {slot:"armor.legs"} run data modify storage macroengine:_item_tmp eq_slot set value "armor.legs"
execute if data storage macroengine:_item_tmp {slot:"armor.feet"} run data modify storage macroengine:_item_tmp eq_slot set value "armor.feet"
execute if data storage macroengine:_item_tmp {slot:"weapon.offhand"} run data modify storage macroengine:_item_tmp slot_src set value "equipment"
execute if data storage macroengine:_item_tmp {slot:"offhand"} run data modify storage macroengine:_item_tmp slot_src set value "equipment"
execute if data storage macroengine:_item_tmp {slot:"weapon.offhand"} run data modify storage macroengine:_item_tmp eq_key set value "offhand"
execute if data storage macroengine:_item_tmp {slot:"offhand"} run data modify storage macroengine:_item_tmp eq_key set value "offhand"
execute if data storage macroengine:_item_tmp {slot:"armor.head"} run data modify storage macroengine:_item_tmp slot_src set value "equipment"
execute if data storage macroengine:_item_tmp {slot:"armor.head"} run data modify storage macroengine:_item_tmp eq_key set value "head"
execute if data storage macroengine:_item_tmp {slot:"armor.chest"} run data modify storage macroengine:_item_tmp slot_src set value "equipment"
execute if data storage macroengine:_item_tmp {slot:"armor.chest"} run data modify storage macroengine:_item_tmp eq_key set value "chest"
execute if data storage macroengine:_item_tmp {slot:"armor.legs"} run data modify storage macroengine:_item_tmp slot_src set value "equipment"
execute if data storage macroengine:_item_tmp {slot:"armor.legs"} run data modify storage macroengine:_item_tmp eq_key set value "legs"
execute if data storage macroengine:_item_tmp {slot:"armor.feet"} run data modify storage macroengine:_item_tmp slot_src set value "equipment"
execute if data storage macroengine:_item_tmp {slot:"armor.feet"} run data modify storage macroengine:_item_tmp eq_key set value "feet"
execute if data storage macroengine:_item_tmp {slot:"hotbar.0"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"hotbar.0"} run data modify storage macroengine:_item_tmp slot_n set value 0
execute if data storage macroengine:_item_tmp {slot:"hotbar.1"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"hotbar.1"} run data modify storage macroengine:_item_tmp slot_n set value 1
execute if data storage macroengine:_item_tmp {slot:"hotbar.2"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"hotbar.2"} run data modify storage macroengine:_item_tmp slot_n set value 2
execute if data storage macroengine:_item_tmp {slot:"hotbar.3"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"hotbar.3"} run data modify storage macroengine:_item_tmp slot_n set value 3
execute if data storage macroengine:_item_tmp {slot:"hotbar.4"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"hotbar.4"} run data modify storage macroengine:_item_tmp slot_n set value 4
execute if data storage macroengine:_item_tmp {slot:"hotbar.5"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"hotbar.5"} run data modify storage macroengine:_item_tmp slot_n set value 5
execute if data storage macroengine:_item_tmp {slot:"hotbar.6"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"hotbar.6"} run data modify storage macroengine:_item_tmp slot_n set value 6
execute if data storage macroengine:_item_tmp {slot:"hotbar.7"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"hotbar.7"} run data modify storage macroengine:_item_tmp slot_n set value 7
execute if data storage macroengine:_item_tmp {slot:"hotbar.8"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"hotbar.8"} run data modify storage macroengine:_item_tmp slot_n set value 8
execute if data storage macroengine:_item_tmp {slot:"inventory.0"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"inventory.0"} run data modify storage macroengine:_item_tmp slot_n set value 9
execute if data storage macroengine:_item_tmp {slot:"inventory.1"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"inventory.1"} run data modify storage macroengine:_item_tmp slot_n set value 10
execute if data storage macroengine:_item_tmp {slot:"inventory.2"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"inventory.2"} run data modify storage macroengine:_item_tmp slot_n set value 11
execute if data storage macroengine:_item_tmp {slot:"inventory.3"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"inventory.3"} run data modify storage macroengine:_item_tmp slot_n set value 12
execute if data storage macroengine:_item_tmp {slot:"inventory.4"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"inventory.4"} run data modify storage macroengine:_item_tmp slot_n set value 13
execute if data storage macroengine:_item_tmp {slot:"inventory.5"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"inventory.5"} run data modify storage macroengine:_item_tmp slot_n set value 14
execute if data storage macroengine:_item_tmp {slot:"inventory.6"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"inventory.6"} run data modify storage macroengine:_item_tmp slot_n set value 15
execute if data storage macroengine:_item_tmp {slot:"inventory.7"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"inventory.7"} run data modify storage macroengine:_item_tmp slot_n set value 16
execute if data storage macroengine:_item_tmp {slot:"inventory.8"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"inventory.8"} run data modify storage macroengine:_item_tmp slot_n set value 17
execute if data storage macroengine:_item_tmp {slot:"inventory.9"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"inventory.9"} run data modify storage macroengine:_item_tmp slot_n set value 18
execute if data storage macroengine:_item_tmp {slot:"inventory.10"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"inventory.10"} run data modify storage macroengine:_item_tmp slot_n set value 19
execute if data storage macroengine:_item_tmp {slot:"inventory.11"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"inventory.11"} run data modify storage macroengine:_item_tmp slot_n set value 20
execute if data storage macroengine:_item_tmp {slot:"inventory.12"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"inventory.12"} run data modify storage macroengine:_item_tmp slot_n set value 21
execute if data storage macroengine:_item_tmp {slot:"inventory.13"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"inventory.13"} run data modify storage macroengine:_item_tmp slot_n set value 22
execute if data storage macroengine:_item_tmp {slot:"inventory.14"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"inventory.14"} run data modify storage macroengine:_item_tmp slot_n set value 23
execute if data storage macroengine:_item_tmp {slot:"inventory.15"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"inventory.15"} run data modify storage macroengine:_item_tmp slot_n set value 24
execute if data storage macroengine:_item_tmp {slot:"inventory.16"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"inventory.16"} run data modify storage macroengine:_item_tmp slot_n set value 25
execute if data storage macroengine:_item_tmp {slot:"inventory.17"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"inventory.17"} run data modify storage macroengine:_item_tmp slot_n set value 26
execute if data storage macroengine:_item_tmp {slot:"inventory.18"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"inventory.18"} run data modify storage macroengine:_item_tmp slot_n set value 27
execute if data storage macroengine:_item_tmp {slot:"inventory.19"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"inventory.19"} run data modify storage macroengine:_item_tmp slot_n set value 28
execute if data storage macroengine:_item_tmp {slot:"inventory.20"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"inventory.20"} run data modify storage macroengine:_item_tmp slot_n set value 29
execute if data storage macroengine:_item_tmp {slot:"inventory.21"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"inventory.21"} run data modify storage macroengine:_item_tmp slot_n set value 30
execute if data storage macroengine:_item_tmp {slot:"inventory.22"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"inventory.22"} run data modify storage macroengine:_item_tmp slot_n set value 31
execute if data storage macroengine:_item_tmp {slot:"inventory.23"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"inventory.23"} run data modify storage macroengine:_item_tmp slot_n set value 32
execute if data storage macroengine:_item_tmp {slot:"inventory.24"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"inventory.24"} run data modify storage macroengine:_item_tmp slot_n set value 33
execute if data storage macroengine:_item_tmp {slot:"inventory.25"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"inventory.25"} run data modify storage macroengine:_item_tmp slot_n set value 34
execute if data storage macroengine:_item_tmp {slot:"inventory.26"} run data modify storage macroengine:_item_tmp slot_src set value "inventory"
execute if data storage macroengine:_item_tmp {slot:"inventory.26"} run data modify storage macroengine:_item_tmp slot_n set value 35
