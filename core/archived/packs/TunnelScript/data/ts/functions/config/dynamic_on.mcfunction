# Allow stored command strings to execute through the command-block runner.
# OFF is the default: ts:run & friends are previewed/blocked until an
# operator turns this on. The tunnelscript.trusted tag and the
# confirmation gate (ts:gate/yes) are still required on top of this.
scoreboard players set #dynamic_enabled tunnelscript.vars 1
tellraw @s [{"text":"[TunnelScript] ","color":"aqua"},{"text":"dynamic commands ON","color":"gold"},{"text":" - stored commands can execute (trusted + confirmation still required)","color":"gray"}]
