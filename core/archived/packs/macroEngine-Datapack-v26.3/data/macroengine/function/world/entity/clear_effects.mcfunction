# ─────────────────────────────────────────────────────────────────
# macroengine:world/entity/clear_effects
# Clears all active potion effects from entities matching type+tag.
#
# INPUT : $(type) → entity type selector (e.g. "minecraft:player")
#         $(tag)  → entity tag filter
# ─────────────────────────────────────────────────────────────────

$effect clear @e[type=$(type),tag=$(tag)]
