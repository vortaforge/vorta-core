# macroengine:core/internal/api/cb/repeat_build [INTERNAL]
# Appends macroengine:input cb.cmd to cb.cmds, #cb_rep_n times (counts #cb_rep_n down to 0).
data modify storage macroengine:input cb.cmds append from storage macroengine:input cb.cmd
scoreboard players remove #cb_rep_n macroengine.tmp 1
execute if score #cb_rep_n macroengine.tmp matches 1.. run function macroengine:core/internal/api/cb/repeat_build
