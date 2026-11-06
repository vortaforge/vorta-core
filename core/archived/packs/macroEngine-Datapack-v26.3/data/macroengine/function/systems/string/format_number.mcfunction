# ─────────────────────────────────────────────────────────────────
# macroengine:systems/string/format_number
# Converts large numbers to readable abbreviations.
#  Input : $(value) → integer
# Output: macroengine:output value → original value
# macroengine:output suffix → k / M / B / "" suffix
# macroengine:output short → abbreviated integer part (see note below)
#
# NOTE: there is no "text" output — mcfunction alone cannot join a
# number and a string into one storage string. Combine short+suffix
# yourself via tellraw, the same way format_coords/ordinal do:
#   function macroengine:systems/string/format_number {value:2500000}
#   tellraw @a ["",
#     {"plain":true ,"storage":"macroengine:output","nbt":"short"},
#     {"plain":true ,"storage":"macroengine:output","nbt":"suffix","color":"gold"}]
#   → 2500000 → short=25, suffix="M" → displays "25M"
#     (short keeps one implied decimal digit above 999 — divide by 10
#      yourself if you want "2.5M" instead of "25M")
#
# Examples:
# 500 → short=500, suffix=""
# 1500 → short=15, suffix="k"
# 1000000 → short=10, suffix="M"
# 2500000 → short=25, suffix="M"
# 1000000000 → short=10, suffix="B"
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{string:0b} run return 0
$scoreboard players set $fn_v macroengine.tmp $(value)
execute store result storage macroengine:output value int 1 run scoreboard players get $fn_v macroengine.tmp

# < 1000 → plain number
execute if score $fn_v macroengine.tmp matches ..999 run data modify storage macroengine:output suffix set value ""
execute if score $fn_v macroengine.tmp matches ..999 run execute store result storage macroengine:output short int 1 run scoreboard players get $fn_v macroengine.tmp
execute if score $fn_v macroengine.tmp matches ..999 run return 0

# 1000 – 999999 → k
execute if score $fn_v macroengine.tmp matches 1000..999999 run data modify storage macroengine:output suffix set value "k"
execute if score $fn_v macroengine.tmp matches 1000..999999 run scoreboard players set $fn_div macroengine.tmp 100
execute if score $fn_v macroengine.tmp matches 1000..999999 run scoreboard players operation $fn_v macroengine.tmp /= $fn_div macroengine.tmp
execute store result storage macroengine:output short int 1 run scoreboard players get $fn_v macroengine.tmp
execute if score $fn_v macroengine.tmp matches 1000..999999 run return 0

# 1_000_000 – 999_999_999 → M
execute if score $fn_v macroengine.tmp matches 1000000..999999999 run data modify storage macroengine:output suffix set value "M"
execute if score $fn_v macroengine.tmp matches 1000000..999999999 run scoreboard players set $fn_div macroengine.tmp 100000
execute if score $fn_v macroengine.tmp matches 1000000..999999999 run scoreboard players operation $fn_v macroengine.tmp /= $fn_div macroengine.tmp
execute store result storage macroengine:output short int 1 run scoreboard players get $fn_v macroengine.tmp
execute if score $fn_v macroengine.tmp matches 1000000..999999999 run return 0

# >= 1_000_000_000 → B
execute if score $fn_v macroengine.tmp matches 1000000000.. run data modify storage macroengine:output suffix set value "B"
execute if score $fn_v macroengine.tmp matches 1000000000.. run scoreboard players set $fn_div macroengine.tmp 100000000
execute if score $fn_v macroengine.tmp matches 1000000000.. run scoreboard players operation $fn_v macroengine.tmp /= $fn_div macroengine.tmp
execute store result storage macroengine:output short int 1 run scoreboard players get $fn_v macroengine.tmp
