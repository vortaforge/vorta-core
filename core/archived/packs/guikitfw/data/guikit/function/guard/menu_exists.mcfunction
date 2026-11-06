# macro $(id)
$execute if data storage guikit:lib menus.$(id) run scoreboard players set #ok guikit.const 1
$execute unless data storage guikit:lib menus.$(id) run scoreboard players set #ok guikit.const 0
