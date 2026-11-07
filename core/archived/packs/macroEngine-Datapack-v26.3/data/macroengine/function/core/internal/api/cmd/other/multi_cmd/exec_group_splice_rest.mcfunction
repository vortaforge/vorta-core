# ─────────────────────────────────────────────────────────────────
# macroengine:core/internal/api/cmd/other/multi_cmd/exec_group_splice_rest
# Appends the entries still queued behind the group, one at a time, to
# the new queue. `data modify ... append from` would push the whole list
# as a single element, so the items have to be moved individually.
# ─────────────────────────────────────────────────────────────────

execute unless data storage macroengine:engine _mcmd_oldq[0] run return 0

data modify storage macroengine:engine _mcmd_newq append from storage macroengine:engine _mcmd_oldq[0]
data remove storage macroengine:engine _mcmd_oldq[0]

function macroengine:core/internal/api/cmd/other/multi_cmd/exec_group_splice_rest
