# ─────────────────────────────────────────────────────────────────
# macroengine:systems/logic/if_not [MACRO]
# Dispatches func only if value is zero (logical NOT).
#  Input : $(value) — score value (0 = true); $(func) — function id
#
# Example: function macroengine:systems/logic/if_not {value:0,func:"my:ns/run"}
# ─────────────────────────────────────────────────────────────────

execute if data storage macroengine:engine modules{logic:0b} run return 0
$scoreboard players set $if_not_v macroengine.tmp $(value)
$data modify storage macroengine:engine _dispatch.func set value "$(func)"
execute if score $if_not_v macroengine.tmp matches 0 run function #macroengine:internal/dispatch
