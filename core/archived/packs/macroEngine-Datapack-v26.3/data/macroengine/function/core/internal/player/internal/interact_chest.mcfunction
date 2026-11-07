# macroEngine player module — advancement relay for 'interact_chest'.
# Advancements can only reward plain functions, so this entry exists to
# forward the trigger into the internal dispatch tag, which other packs
# may extend. Fired when the player used a chest (advancement-driven).

function #macroengine:core/internal/player/internal/interact_chest
