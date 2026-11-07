# macroengine:core/internal/tui/button_send [INTERNAL, MACRO]
# Sends one clickable button to @s. The ONLY macro argument is $(fn), which tui/button has already
# checked with systems/validate/function_id while it was still data. Label and hover text come from
# storage (macroengine:tui l / h) as plain strings and are never pasted into this line.
execute if data storage macroengine:engine modules{cmd:0b} run return 0

$tellraw @s ["",{"text":"[ ","color":"dark_gray"},{"storage":"macroengine:tui","nbt":"l","interpret":true,"plain":false,"color":"green","click_event":{"action":"run_command","command":"/function $(fn)"},"hover_event":{"action":"show_text","value":{"storage":"macroengine:tui","nbt":"h","interpret":true,"plain":false,"color":"gray"}}},{"text":" ]","color":"dark_gray"}]