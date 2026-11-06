# Mirror lib → reg (bare keys). Other packs can also listen on #guikit:register.
data modify storage guikit:reg menus set from storage guikit:lib menus
function #guikit:register
