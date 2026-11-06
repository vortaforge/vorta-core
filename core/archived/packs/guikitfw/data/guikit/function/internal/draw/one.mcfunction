# Dispatch widget kind → widget/<kind> place + record action if interactive
data modify storage guikit:work kind set from storage guikit:draw w.kind
function guikit:internal/draw/one_kind with storage guikit:work
