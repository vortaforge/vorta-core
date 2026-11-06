# ─────────────────────────────────────────────────────────────────
# macroengine:systems/string/roman [MACRO]
# Converts an integer 1..3999 to a Roman numeral string.
#  Input : $(n)
# Output: macroengine:output result → "XIV"; "" when n is outside 1..3999
#
# Example: function macroengine:systems/string/roman {n:1994}  → "MCMXCIV"
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{string:0b} run return 0
$scoreboard players set $rm_n macroengine.tmp $(n)
data modify storage macroengine:output result set value ""
execute unless score $rm_n macroengine.tmp matches 1..3999 run return 0

scoreboard players set $rm_1000 macroengine.tmp 1000
scoreboard players set $rm_100 macroengine.tmp 100
scoreboard players set $rm_10 macroengine.tmp 10
scoreboard players operation $rm_t macroengine.tmp = $rm_n macroengine.tmp
scoreboard players operation $rm_t macroengine.tmp /= $rm_1000 macroengine.tmp
scoreboard players operation $rm_h macroengine.tmp = $rm_n macroengine.tmp
scoreboard players operation $rm_h macroengine.tmp %= $rm_1000 macroengine.tmp
scoreboard players operation $rm_h macroengine.tmp /= $rm_100 macroengine.tmp
scoreboard players operation $rm_te macroengine.tmp = $rm_n macroengine.tmp
scoreboard players operation $rm_te macroengine.tmp %= $rm_100 macroengine.tmp
scoreboard players operation $rm_te macroengine.tmp /= $rm_10 macroengine.tmp
scoreboard players operation $rm_o macroengine.tmp = $rm_n macroengine.tmp
scoreboard players operation $rm_o macroengine.tmp %= $rm_10 macroengine.tmp

data modify storage macroengine:tmp roman set value {t:"",h:"",te:"",o:""}

# thousands
execute if score $rm_t macroengine.tmp matches 1 run data modify storage macroengine:tmp roman.t set value "M"
execute if score $rm_t macroengine.tmp matches 2 run data modify storage macroengine:tmp roman.t set value "MM"
execute if score $rm_t macroengine.tmp matches 3 run data modify storage macroengine:tmp roman.t set value "MMM"

# h
execute if score $rm_h macroengine.tmp matches 1 run data modify storage macroengine:tmp roman.h set value "C"
execute if score $rm_h macroengine.tmp matches 2 run data modify storage macroengine:tmp roman.h set value "CC"
execute if score $rm_h macroengine.tmp matches 3 run data modify storage macroengine:tmp roman.h set value "CCC"
execute if score $rm_h macroengine.tmp matches 4 run data modify storage macroengine:tmp roman.h set value "CD"
execute if score $rm_h macroengine.tmp matches 5 run data modify storage macroengine:tmp roman.h set value "D"
execute if score $rm_h macroengine.tmp matches 6 run data modify storage macroengine:tmp roman.h set value "DC"
execute if score $rm_h macroengine.tmp matches 7 run data modify storage macroengine:tmp roman.h set value "DCC"
execute if score $rm_h macroengine.tmp matches 8 run data modify storage macroengine:tmp roman.h set value "DCCC"
execute if score $rm_h macroengine.tmp matches 9 run data modify storage macroengine:tmp roman.h set value "CM"

# te
execute if score $rm_te macroengine.tmp matches 1 run data modify storage macroengine:tmp roman.te set value "X"
execute if score $rm_te macroengine.tmp matches 2 run data modify storage macroengine:tmp roman.te set value "XX"
execute if score $rm_te macroengine.tmp matches 3 run data modify storage macroengine:tmp roman.te set value "XXX"
execute if score $rm_te macroengine.tmp matches 4 run data modify storage macroengine:tmp roman.te set value "XL"
execute if score $rm_te macroengine.tmp matches 5 run data modify storage macroengine:tmp roman.te set value "L"
execute if score $rm_te macroengine.tmp matches 6 run data modify storage macroengine:tmp roman.te set value "LX"
execute if score $rm_te macroengine.tmp matches 7 run data modify storage macroengine:tmp roman.te set value "LXX"
execute if score $rm_te macroengine.tmp matches 8 run data modify storage macroengine:tmp roman.te set value "LXXX"
execute if score $rm_te macroengine.tmp matches 9 run data modify storage macroengine:tmp roman.te set value "XC"

# o
execute if score $rm_o macroengine.tmp matches 1 run data modify storage macroengine:tmp roman.o set value "I"
execute if score $rm_o macroengine.tmp matches 2 run data modify storage macroengine:tmp roman.o set value "II"
execute if score $rm_o macroengine.tmp matches 3 run data modify storage macroengine:tmp roman.o set value "III"
execute if score $rm_o macroengine.tmp matches 4 run data modify storage macroengine:tmp roman.o set value "IV"
execute if score $rm_o macroengine.tmp matches 5 run data modify storage macroengine:tmp roman.o set value "V"
execute if score $rm_o macroengine.tmp matches 6 run data modify storage macroengine:tmp roman.o set value "VI"
execute if score $rm_o macroengine.tmp matches 7 run data modify storage macroengine:tmp roman.o set value "VII"
execute if score $rm_o macroengine.tmp matches 8 run data modify storage macroengine:tmp roman.o set value "VIII"
execute if score $rm_o macroengine.tmp matches 9 run data modify storage macroengine:tmp roman.o set value "IX"

function macroengine:systems/string/roman_join with storage macroengine:tmp roman
data remove storage macroengine:tmp roman
scoreboard players reset $rm_n macroengine.tmp
scoreboard players reset $rm_t macroengine.tmp
scoreboard players reset $rm_h macroengine.tmp
scoreboard players reset $rm_te macroengine.tmp
scoreboard players reset $rm_o macroengine.tmp
scoreboard players reset $rm_1000 macroengine.tmp
scoreboard players reset $rm_100 macroengine.tmp
scoreboard players reset $rm_10 macroengine.tmp
