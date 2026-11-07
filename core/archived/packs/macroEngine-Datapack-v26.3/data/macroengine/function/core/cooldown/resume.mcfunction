# macroengine:core/cooldown/resume
# Resumes a previously paused cooldown.
# Params: player, key
# Output: macroengine:output result (new expiry epoch tick), 0b if not paused

data modify storage macroengine:output result set value 0b

$execute unless data storage macroengine:engine paused_cooldowns.$(player).$(key) run return 0

# Reconstruct expiry: now + saved remaining ticks
$execute store result score $cdr_rem macroengine.tmp run data get storage macroengine:engine paused_cooldowns.$(player).$(key)
execute store result score $cdr_now macroengine.tmp run scoreboard players get $epoch macroengine.time
scoreboard players operation $cdr_now macroengine.tmp += $cdr_rem macroengine.tmp

# Write back to live cooldowns, remove from paused
$execute store result storage macroengine:engine cooldowns.$(player).$(key) int 1 run scoreboard players get $cdr_now macroengine.tmp
$data remove storage macroengine:engine paused_cooldowns.$(player).$(key)
execute store result storage macroengine:output result int 1 run scoreboard players get $cdr_now macroengine.tmp