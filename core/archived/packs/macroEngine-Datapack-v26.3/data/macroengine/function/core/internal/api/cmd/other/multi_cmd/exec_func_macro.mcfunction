# ─────────────────────────────────────────────────────────────────
# macroengine:api/cmd/other/multi_cmd/internal/exec_func_macro [MACRO]
# INPUT: $(func)
# ─────────────────────────────────────────────────────────────────

# Dynamic commands are off by default (config dynamic_cmd). See docs/cmd_gate.md.
execute unless data storage macroengine:engine config{dynamic_cmd:1b} run return 0
$function $(func)
