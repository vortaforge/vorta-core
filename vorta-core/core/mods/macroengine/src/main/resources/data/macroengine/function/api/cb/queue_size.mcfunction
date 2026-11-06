# macroengine:api/cb/queue_size
# ─────────────────────────────────────────────────────────────────
# Returns the number of pending delayed CB commands.
# Result is stored in score #cb_queue_size macroengine.tmp.
#
# EXAMPLE:
#   function macroengine:api/cb/queue_size
#   # read: scoreboard players get #cb_queue_size macroengine.tmp
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{cb:0b} run return 0
execute store result score #cb_queue_size macroengine.tmp run data get storage macroengine:engine cb_queue
