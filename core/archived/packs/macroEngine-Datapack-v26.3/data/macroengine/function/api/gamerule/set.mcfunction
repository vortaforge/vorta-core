# macroengine:api/gamerule/set [MACRO]
# Sets a custom gamerule value, persists it in storage, and dispatches
# a callback function when the value matches a defined condition.
#
# INPUT (macro args via `with storage macroengine:input {}`):
#   $(rule)      — rule name string, e.g. "pvp_enabled"
#   $(value)     — value string: "true", "false", or a number string e.g. "10"
#
# OPTIONAL storage keys (set before calling, removed after):
#   macroengine:input gr_on_true   — function to call when value is "true"
#   macroengine:input gr_on_false  — function to call when value is "false"
#   macroengine:input gr_on_value  — function to call for any numeric match
#   macroengine:input gr_matches   — scoreboard range string, e.g. "5..10" (used with gr_on_value)
#
# EXAMPLE:
#   data modify storage macroengine:input rule set value "pvp_enabled"
#   data modify storage macroengine:input value set value "true"
#   data modify storage macroengine:input gr_on_true set value "mypack:pvp/enable"
#   data modify storage macroengine:input gr_on_false set value "mypack:pvp/disable"
#   function macroengine:api/gamerule/set with storage macroengine:input {}
#
# RETURN: 1 on success, 0 on guard failure.


# Normalize key (spaces -> underscores, lowercase). Leaves _gamerule_norm unset when
# the name cannot be normalized safely (contains a quote or a backslash).
execute if data storage macroengine:engine modules{gamerule:0b} run return 0
data remove storage macroengine:input _gamerule_norm
function macroengine:core/internal/api/gamerule/normalize

# ── Persist value in engine storage ──────────────────────────────────────────
function macroengine:core/internal/api/gamerule/persist with storage macroengine:input {}

# ── Dispatch callbacks ────────────────────────────────────────────────────────
function macroengine:core/internal/api/gamerule/dispatch with storage macroengine:input {}

# ── Cleanup ───────────────────────────────────────────────────────────────────
data remove storage macroengine:input _gamerule_norm
