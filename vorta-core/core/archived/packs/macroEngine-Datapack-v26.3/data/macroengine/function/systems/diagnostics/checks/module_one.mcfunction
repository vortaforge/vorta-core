# macroengine:systems/diagnostics/checks/module_one [MACRO: name]
# Internal: checks one module. $(name) comes only from the constant list in checks/modules.
# Codes: module.missing:<name>  module.invalid:<name>  module.mismatch:<name>

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0

$execute unless data storage macroengine:engine modules.$(name) run data modify storage macroengine:output diagnostics.issues append value "module.missing:$(name)"
$execute if data storage macroengine:engine modules{$(name):1b} run scoreboard players add #macroengine.dg_on macroengine.tmp 1
$execute if data storage macroengine:engine modules{$(name):0b} run scoreboard players add #macroengine.dg_off macroengine.tmp 1
$execute if data storage macroengine:engine modules.$(name) unless data storage macroengine:engine modules{$(name):1b} unless data storage macroengine:engine modules{$(name):0b} run data modify storage macroengine:output diagnostics.issues append value "module.invalid:$(name)"
$execute if data storage macroengine:engine modules{$(name):1b} unless data storage macroengine:engine config{module_$(name):1b} run data modify storage macroengine:output diagnostics.issues append value "module.mismatch:$(name)"
$execute if data storage macroengine:engine modules{$(name):0b} unless data storage macroengine:engine config{module_$(name):0b} run data modify storage macroengine:output diagnostics.issues append value "module.mismatch:$(name)"
