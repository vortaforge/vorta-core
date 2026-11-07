# macroEngine player module — advancement relay for 'attack_click_entity'.
# Advancements can only reward plain functions, so this entry exists to
# forward the trigger into the internal dispatch tag, which other packs
# may extend. Fired when left-click (attack) detection fired for @s.

function #macroengine:core/internal/player/internal/attack_click_entity
