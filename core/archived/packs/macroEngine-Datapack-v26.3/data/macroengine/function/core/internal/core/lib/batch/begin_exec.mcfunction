# macroengine:core/lib/batch/internal/begin_exec [MACRO]
# INPUT: $(id), $(spread_over)

$data modify storage macroengine:engine batches.$(id) set value {items:[],spread_over:$(spread_over),flushed:0b}
