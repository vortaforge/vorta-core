# macroengine:core/internal/text/split_emit [INTERNAL] appends win to out unless it is empty and empties are dropped
execute store result score #tx_wl macroengine.tmp run data get storage macroengine:text win
execute if score #tx_wl macroengine.tmp matches 1.. run data modify storage macroengine:text out append from storage macroengine:text win
execute if score #tx_wl macroengine.tmp matches 0 if score #tx_keep macroengine.tmp matches 1 run data modify storage macroengine:text out append from storage macroengine:text win
