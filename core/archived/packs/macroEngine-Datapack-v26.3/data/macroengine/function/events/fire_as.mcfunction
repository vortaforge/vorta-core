$data modify storage macroengine:engine event_context.player set value "$(player)"

function macroengine:events/fire with storage macroengine:input {}

data remove storage macroengine:engine event_context.player
