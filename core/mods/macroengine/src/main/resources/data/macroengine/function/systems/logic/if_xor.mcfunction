# ─────────────────────────────────────────────────────────────────
# macroengine:systems/logic/if_xor [MACRO]
# Dispatches func only if EXACTLY ONE of a and b is non-zero (logical XOR).
#  Input : $(a), $(b) — score values (non-zero = true); $(func) — function id
#
# Example: function macroengine:systems/logic/if_xor {a:1,b:0,func:"my:ns/run"}
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{logic:0b} run return 0
$scoreboard players set $if_xor_a macroengine.tmp $(a)
$scoreboard players set $if_xor_b macroengine.tmp $(b)
$data modify storage macroengine:engine _dispatch.func set value "$(func)"
execute unless score $if_xor_a macroengine.tmp matches 0 if score $if_xor_b macroengine.tmp matches 0 run function #macroengine:internal/dispatch
execute if score $if_xor_a macroengine.tmp matches 0 unless score $if_xor_b macroengine.tmp matches 0 run function #macroengine:internal/dispatch
