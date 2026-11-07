data modify storage macroengine:output result set value 0
$execute if data storage macroengine:engine events.$(event) run execute store result storage macroengine:output result int 1 run data get storage macroengine:engine events.$(event)
