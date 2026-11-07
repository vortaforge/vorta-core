# macroEngine player module — advancement relay for 'interact_click_entity'.
# Advancements can only reward plain functions, so this entry exists to
# forward the trigger into the internal dispatch tag, which other packs
# may extend. Fired when right-click-on-entity detection fired for @s.

function #macroengine:core/internal/player/internal/interact_click_entity
