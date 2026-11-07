# ─────────────────────────────────────────────────────────────────
# macroengine:api/cmd/other/multi_cmd/internal/exec_macro [MACRO]
# INPUT: $(cmd)
# ─────────────────────────────────────────────────────────────────

# Keep the raw command as data first, then run the real gate on it:
# systems/cmd_gate/check (config dynamic_cmd + permission cmd.dynamic +
# length/control checks + blocklist). Only a command that passes is
# macro-executed below; a denied command is dropped, not run.
$data modify storage macroengine:input raw_command set value "$(cmd)"
data modify storage macroengine:cmd_gate in.cmd set from storage macroengine:input raw_command
execute unless function macroengine:systems/cmd_gate/check run return 0

tellraw @a[tag=macroengine.admin] [{"selector":"@s","color":"gold"},{"text":" - command passed the dynamic-command gate","color":"yellow"}]

$$(cmd)
