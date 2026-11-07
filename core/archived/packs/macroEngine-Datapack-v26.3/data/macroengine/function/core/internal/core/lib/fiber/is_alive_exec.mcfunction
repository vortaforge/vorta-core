# macroengine:core/lib/fiber/internal/is_alive_exec [MACRO]
# INPUT: $(id)

data modify storage macroengine:output result set value 0b
$execute if data storage macroengine:engine fibers.$(id){alive:1b} run data modify storage macroengine:output result set value 1b