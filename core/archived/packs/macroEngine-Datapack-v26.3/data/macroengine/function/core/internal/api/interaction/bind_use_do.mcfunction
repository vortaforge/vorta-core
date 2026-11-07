# macroengine:api/interaction/internal/bind_use_do [MACRO] [INTERNAL]
# Called by bind_use with storage macroengine:input {} to do the actual append.
# INPUT: $(tag), $(func)
$data modify storage macroengine:engine interaction_binds.use append value {tag:"$(tag)", func:"$(func)"}