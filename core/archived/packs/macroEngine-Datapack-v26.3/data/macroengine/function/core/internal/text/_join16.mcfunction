# macroengine:core/internal/text/_join16 [MACRO]
# INPUT $(p0)..$(p15): up to 16 quote-free strings. Joined into storage macroengine:text jout.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$data modify storage macroengine:text jout set value "$(p0)$(p1)$(p2)$(p3)$(p4)$(p5)$(p6)$(p7)$(p8)$(p9)$(p10)$(p11)$(p12)$(p13)$(p14)$(p15)"
