data remove storage guikit:work url
data modify storage guikit:work url set from storage guikit:act w.url
execute unless data storage guikit:work url run return 0
function guikit:act/_link_show with storage guikit:work
function guikit:api/close
