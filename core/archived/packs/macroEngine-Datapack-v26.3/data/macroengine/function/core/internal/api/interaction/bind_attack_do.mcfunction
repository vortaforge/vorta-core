# macroengine:api/interaction/internal/bind_attack_do [MACRO] [INTERNAL]
# Called by bind_attack with storage macroengine:input {} to do the actual append.
# INPUT: $(tag), $(func)
$data modify storage macroengine:engine interaction_binds.attack append value {tag:"$(tag)", func:"$(func)"}