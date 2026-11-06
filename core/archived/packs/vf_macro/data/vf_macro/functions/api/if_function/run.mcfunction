# PUBLIC API — vf_macro:api/if_function/run
#
# Simulates `execute if function <id>` by:
#   1. Clearing the returned flag + return storage
#   2. Running the target command through the command-block engine
#   3. Scheduling a short-delay check that sets #vf_macro.if_success
#
# The check combines two signals:
#   - Command-block SuccessCount (0 = invalid command / missing function)
#   - Explicit return API (return/fail → 0, return/success or return/value → 1)
#
# IMPORTANT — TIMING:
#   The engine is asynchronous. #vf_macro.if_success becomes valid ~2 ticks later.
#
# Usage:
#   data modify storage vf_macro:in Command set value "function mypack:test"
#   function vf_macro:api/if_function/run
#   # wait ≥ 2 ticks, then:
#   execute if score #vf_macro.if_success vf_macro matches 1 run say success
#   execute if score #vf_macro.if_success vf_macro matches 0 run say failed
#
# Note: Supply the FULL command string (including the word "function ").

scoreboard players set #vf_macro.returned vf_macro 0
scoreboard players reset #vf_macro.if_success vf_macro
data remove storage vf_macro:out return_success
data remove storage vf_macro:out return_value
scoreboard players set #vf_macro.skip vf_macro 0

# Prefer vf_macro:in Command, fall back to mce:cmd Command
execute unless data storage vf_macro:in Command unless data storage mce:cmd Command run tellraw @a [{"text":"[VF Macro] ","color":"red"},{"text":"ERROR: no Command set in vf_macro:in or mce:cmd","color":"white"}]
execute unless data storage vf_macro:in Command unless data storage mce:cmd Command run scoreboard players set #vf_macro.if_success vf_macro 0
execute unless data storage vf_macro:in Command unless data storage mce:cmd Command run scoreboard players set #vf_macro.skip vf_macro 1

# Run via macro API only when we have a command
execute if score #vf_macro.skip vf_macro matches 0 if data storage vf_macro:in Command run function vf_macro:api/macro/run
execute if score #vf_macro.skip vf_macro matches 0 unless data storage vf_macro:in Command if data storage mce:cmd Command run function mce:api/run/cmd

# Schedule the result mapping (2t is safe relative to the engine's 3t reset)
execute if score #vf_macro.skip vf_macro matches 0 run schedule function vf_macro:api/if_function/check 2t replace
