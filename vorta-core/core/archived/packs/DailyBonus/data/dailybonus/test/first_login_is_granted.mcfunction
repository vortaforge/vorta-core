# @template ward:empty/3x3x3
# @dummy ~1 ~ ~1
# @max_ticks 60

# Ward test (CI only, never shipped in runtime ZIPs): a player who has never
# claimed has NO db_last_day score. The unset-score grant in tick.mcfunction
# must hand them the bonus once, and the "< #day" comparison below it must then
# skip them so they are not granted twice.

# Simulate a first login: drop any score the dummy may already have received.
scoreboard players reset @s db_last_day

# tick.mcfunction runs every tick and must give the player a score.
await score @s db_last_day matches 0..

# The grant marks the player as caught up with the current in-game day.
assert score @s db_last_day = #day db_gameday

# Stay caught up across further ticks (no second grant, no regression).
await delay 5t
assert score @s db_last_day = #day db_gameday
