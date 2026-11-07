# macroengine:core/internal/systems/rng/_pick_at [MACRO]
# INPUT: $(index) — position already chosen by systems/rng/pick

$data modify storage macroengine:output result set from storage macroengine:engine _rng_list[$(index)]
