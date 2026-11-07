# macroEngine player module — advancement relay for 'interact_dropper'.
# Advancements can only reward plain functions, so this entry exists to
# forward the trigger into the internal dispatch tag, which other packs
# may extend. @s is the player who triggered the interaction.

function #macroengine:core/internal/player/internal/interact_dropper
