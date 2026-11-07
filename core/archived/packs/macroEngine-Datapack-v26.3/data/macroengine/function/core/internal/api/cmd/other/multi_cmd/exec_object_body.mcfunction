# ─────────────────────────────────────────────────────────────────
# macroengine:core/internal/api/cmd/other/multi_cmd/exec_object_body
# The execution half of exec_object, reached only when the entry's
# condition passed (or it had none). Split out so the gate in
# exec_object can be a plain positive `execute if` with no `return`.
# ─────────────────────────────────────────────────────────────────

# Run pre-hook (if present)
execute if data storage macroengine:engine _mcmd_current.pre_hook run function macroengine:core/internal/api/cmd/other/multi_cmd/run_pre_hook

# Start profiling (if present)
execute if data storage macroengine:engine _mcmd_options{profile:1b} run execute store result score $mcmd_exec_start macroengine.tmp run time query gametime

# A group entry is expanded rather than run, so `commands` wins when both
# it and cmd/func are present.
execute if data storage macroengine:engine _mcmd_current.commands run function macroengine:core/internal/api/cmd/other/multi_cmd/exec_group
execute unless data storage macroengine:engine _mcmd_current.commands if data storage macroengine:engine _mcmd_current.cmd run function macroengine:core/internal/api/cmd/other/multi_cmd/exec_macro with storage macroengine:engine _mcmd_current
execute unless data storage macroengine:engine _mcmd_current.commands if data storage macroengine:engine _mcmd_current.func run function macroengine:core/internal/api/cmd/other/multi_cmd/exec_func_macro with storage macroengine:engine _mcmd_current

# End profiling (if present)
execute if data storage macroengine:engine _mcmd_options{profile:1b} run function macroengine:core/internal/api/cmd/other/multi_cmd/record_exec_time

# Run post-hook (if present)
execute if data storage macroengine:engine _mcmd_current.post_hook run function macroengine:core/internal/api/cmd/other/multi_cmd/run_post_hook

execute if data storage macroengine:engine _mcmd_options{profile:1b} run scoreboard players add $mcmd_success macroengine.tmp 1
