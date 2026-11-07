# macroengine:core/lib/batch/internal/cancel_exec [MACRO]
# INPUT: $(id)

$execute unless data storage macroengine:engine batches.$(id) run return 0
$data remove storage macroengine:engine batches.$(id)