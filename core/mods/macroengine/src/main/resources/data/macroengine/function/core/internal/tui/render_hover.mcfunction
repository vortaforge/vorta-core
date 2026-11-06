# macroengine:core/internal/tui/render_hover [INTERNAL]
# Renders macroengine:tui in.hover (with %tokens%, in.args) into the plain string macroengine:tui h.
# Falls back to "Click to run" when in.hover is missing or invalid.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data remove storage macroengine:tui h
data remove storage macroengine:store in
execute if data storage macroengine:tui in.hover run data modify storage macroengine:store in.template set from storage macroengine:tui in.hover
execute if data storage macroengine:tui in.hover if data storage macroengine:tui in.args run data modify storage macroengine:store in.args set from storage macroengine:tui in.args
execute if data storage macroengine:tui in.hover if function macroengine:api/store/render run data modify storage macroengine:tui h set from storage macroengine:store out.string
execute unless data storage macroengine:tui h run data modify storage macroengine:tui h set value "Click to run"
