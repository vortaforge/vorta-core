# macroengine:core/internal/text/_num_emit [MACRO]
# INPUT $(s): a string already validated by num_check (digits, one '-', one '.').
$data modify storage macroengine:text out set value $(s)
