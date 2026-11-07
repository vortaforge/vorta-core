# macroengine:core/internal/api/perm/require_eval  [INTERNAL — macro function]
# Only ever called by api/perm/require AFTER $(perm) passed systems/validate/safe_name.
# Do not call directly with unvalidated input.
$execute if entity @s[tag=perm.$(perm)] run data modify storage macroengine:output result set value 1b
