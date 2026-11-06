# macroengine:core/internal/tui/render_label [INTERNAL]
# Renders macroengine:tui in.label (with %tokens%, in.args) into the plain string macroengine:tui l.
# Leaves l unset when in.label is missing or the template is invalid.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data remove storage macroengine:tui l
data remove storage macroengine:store in
execute unless data storage macroengine:tui in.label run return 0
data modify storage macroengine:store in.template set from storage macroengine:tui in.label
execute if data storage macroengine:tui in.args run data modify storage macroengine:store in.args set from storage macroengine:tui in.args
execute if function macroengine:api/store/render run data modify storage macroengine:tui l set from storage macroengine:store out.string
