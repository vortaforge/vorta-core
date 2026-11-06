# macroengine:api/cb/run_repeating
# ─────────────────────────────────────────────────────────────────
# Runs ONE command several times, a fixed number of ticks apart.
# Shorthand for api/cb/run_sequence with the same command repeated.
#
# INPUT  (storage macroengine:input cb):
#   cmd       (string)  — the command to repeat          [REQUIRED]
#   times     (int)     — how many runs, 1..100          [REQUIRED]
#   interval  (int)     — ticks between runs, >= 1       [default: 2]
#   x         (int)     — CB block X  [default: 0]
#   y         (int)     — CB block Y  [default: -64]
#   z         (int)     — CB block Z  [default: 0]
#
# OUTPUT (storage macroengine:output):
#   cb_id   (int)  — one id shared by every run; api/cb/cancel_id cancels the
#                     runs that have not fired yet
#
# Numbers are read as numbers and compared on a scoreboard; cmd is copied
# between storages and never pasted into a macro line. Entries share the
# fire spacing of api/cb (see docs/cb.md), so an interval of 1 runs at 2.
#
# EXAMPLE:
#   data modify storage macroengine:input cb set value {cmd:"say tick",times:5,interval:20}
#   function macroengine:api/cb/run_repeating
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{cb:0b} run return 0
execute unless data storage macroengine:input cb.cmd run tellraw @s [{"text":"[MACROENGINE/cb] ","color":"#00AAAA","bold":true},{"text":"cb.cmd not set","color":"red"}]
execute unless data storage macroengine:input cb.cmd run return 0
execute unless data storage macroengine:input cb.times run tellraw @s [{"text":"[MACROENGINE/cb] ","color":"#00AAAA","bold":true},{"text":"cb.times not set","color":"red"}]
execute unless data storage macroengine:input cb.times run return 0

scoreboard players set #cb_rep_n macroengine.tmp 0
execute store result score #cb_rep_n macroengine.tmp run data get storage macroengine:input cb.times
execute unless score #cb_rep_n macroengine.tmp matches 1..100 run tellraw @s [{"text":"[MACROENGINE/cb] ","color":"#00AAAA","bold":true},{"text":"cb.times must be a number from 1 to 100","color":"red"}]
execute unless score #cb_rep_n macroengine.tmp matches 1..100 run return 0

execute unless data storage macroengine:input cb.interval run data modify storage macroengine:input cb.interval set value 2
scoreboard players set #cb_rep_i macroengine.tmp 0
execute store result score #cb_rep_i macroengine.tmp run data get storage macroengine:input cb.interval
execute unless score #cb_rep_i macroengine.tmp matches 1.. run tellraw @s [{"text":"[MACROENGINE/cb] ","color":"#00AAAA","bold":true},{"text":"cb.interval must be a number >= 1","color":"red"}]
execute unless score #cb_rep_i macroengine.tmp matches 1.. run return 0

function macroengine:core/internal/api/cb/apply_defaults

# Build cb.cmds = [cmd, cmd, ...] (times copies), then hand it to the sequence expander
data modify storage macroengine:input cb.cmds set value []
function macroengine:core/internal/api/cb/repeat_build
data remove storage macroengine:input cb.cmd
data remove storage macroengine:input cb.times
function macroengine:core/internal/systems/cb/seq_expand
data remove storage macroengine:input cb
scoreboard players reset #cb_rep_n macroengine.tmp
scoreboard players reset #cb_rep_i macroengine.tmp
