# ─────────────────────────────────────────────────────────────────
# macroengine:systems/text/explain
# Prints the NBT text-component rendering rules this module exists to
# enforce. Useful when debugging output that looks wrong.
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{text:0b} run return 0
tellraw @s [{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"━━━ NBT text components (26.1+) ━━━","color":"#555555"}]
tellraw @s [{"text":"  {storage,nbt}                    ","color":"gray"},{"text":"→  \"Example Text\"  (quotes kept)","color":"red"}]
tellraw @s [{"text":"  {storage,nbt,interpret:true}     ","color":"gray"},{"text":"→  Example Text    (parsed as a component)","color":"yellow"}]
tellraw @s [{"text":"  {storage,nbt,interpret:false,","color":"gray"}]
tellraw @s [{"text":"                     plain:true}   ","color":"gray"},{"text":"→  Example Text    (raw value, no colouring)","color":"green"}]
tellraw @s [{"text":"  Numbers and booleans need plain:true too, or 1b renders coloured.","color":"gray","italic":true}]
tellraw @s [{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━","color":"#555555"}]
