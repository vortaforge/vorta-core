# ─────────────────────────────────────────────────────────────────
# macroengine:systems/text/bool [MACRO]
# Prints an NBT boolean or 0/1 as "yes" / "no".
#
# INPUT: $(storage), $(path)
#
# A raw boolean renders as a coloured 1b, which reads badly in a status
# line. This maps the value instead of printing it. A missing path
# reports "no" rather than nothing, so the line still lines up.
#
# Usage:  function macroengine:systems/text/bool {storage:"macroengine:engine",path:"tick.paused"}
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{text:0b} run return 0
$execute store success score $text_bool_ok macroengine.tmp run data get storage $(storage) $(path)
execute if score $text_bool_ok macroengine.tmp matches 0 run tellraw @s [{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"no","color":"red"}]
$execute if score $text_bool_ok macroengine.tmp matches 1 store result score $text_bool_val macroengine.tmp run data get storage $(storage) $(path)
execute if score $text_bool_ok macroengine.tmp matches 1 if score $text_bool_val macroengine.tmp matches 0 run tellraw @s [{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"no","color":"red"}]
execute if score $text_bool_ok macroengine.tmp matches 1 unless score $text_bool_val macroengine.tmp matches 0 run tellraw @s [{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"yes","color":"green"}]
scoreboard players reset $text_bool_ok macroengine.tmp
scoreboard players reset $text_bool_val macroengine.tmp
