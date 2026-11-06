execute unless data storage guikit:act w.commands[0] run return 0
data modify storage guikit:work cmd set from storage guikit:act w.commands[0]
function guikit:act/_commands_one with storage guikit:work
data remove storage guikit:act w.commands[0]
function guikit:act/_commands
