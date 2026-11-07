# macroengine:api/store/convert
# Turns the string produced by api/store/render (or any string you put in
# macroengine:store out.string) into forms other functions can use. Everything written
# here is a string, int, byte or a list/compound OF strings; no text component is built.
#
# INPUT  macroengine:store out.string   a string (a compound or list is rejected)
# OUTPUT macroengine:store conv.string      the text as an NBT string
#        macroengine:store conv.length      int, number of characters
#        macroengine:store conv.lines       list of strings, split on newlines (%nl%)
#        macroengine:store conv.line_count  int, entries in conv.lines
#        macroengine:store conv.safe        1b when the text has no double quote, backslash,
#                                           newline, carriage return or tab
#        macroengine:store conv.macro       {text:"..."}; only set when conv.safe is 1b. Pass it
#                                           with "with storage macroengine:store conv.macro" to a
#                                           macro function that uses $(text)
#        macroengine:output store.converted mirrors conv.string
# RETURN 1 on success, 0 when out.string is missing or not a string.
#
# Usage:
#   data modify storage macroengine:store in set value {template:"Hi %player%%nl%Coins: %score:coins%"}
#   execute as @p run function macroengine:api/store/render
#   function macroengine:api/store/convert
#   data modify storage mypack:data msg set from storage macroengine:store conv.string
execute if data storage macroengine:engine modules{store:0b} run return 0
data remove storage macroengine:store conv
execute unless data storage macroengine:store out.string run return 0
execute if data storage macroengine:store out.string{} run return 0
execute if data storage macroengine:store out.string[] run return 0

data modify storage macroengine:store conv.string set string storage macroengine:store out.string
execute store result storage macroengine:store conv.length int 1 run data get storage macroengine:store conv.string

# lines
data modify storage macroengine:text s set from storage macroengine:store conv.string
data modify storage macroengine:text sep set value "\n"
data modify storage macroengine:text keep_empty set value 1b
data modify storage macroengine:text n set value 0
execute store result storage macroengine:store conv.line_count int 1 run function macroengine:core/internal/text/split
data modify storage macroengine:store conv.lines set from storage macroengine:text out
function macroengine:core/internal/text/reset

# macro safety: quote/backslash first (text/safe), then newline/CR/tab (text/ctl)
data modify storage macroengine:text s set from storage macroengine:store conv.string
execute store result score #st_cv_a macroengine.tmp run function macroengine:core/internal/text/safe
execute store result score #st_cv_b macroengine.tmp run function macroengine:core/internal/text/ctl
function macroengine:core/internal/text/reset
data modify storage macroengine:store conv.safe set value 0b
execute if score #st_cv_a macroengine.tmp matches 1 if score #st_cv_b macroengine.tmp matches 0 run data modify storage macroengine:store conv.safe set value 1b
execute if data storage macroengine:store conv{safe:1b} run data modify storage macroengine:store conv.macro set value {}
execute if data storage macroengine:store conv{safe:1b} run data modify storage macroengine:store conv.macro.text set from storage macroengine:store conv.string

data modify storage macroengine:output store.converted set from storage macroengine:store conv.string
return 1
