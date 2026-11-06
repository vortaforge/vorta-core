# macroengine:core/internal/api/perm/require_eval  [INTERNAL — macro function]
# Only ever called by api/perm/require AFTER $(perm) passed systems/validate/safe_name.
# Do not call directly with unvalidated input.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$execute if entity @s[tag=perm.$(perm)] run data modify storage macroengine:output result set value 1b
