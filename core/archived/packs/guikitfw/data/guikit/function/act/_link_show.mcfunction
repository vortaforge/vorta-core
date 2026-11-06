# macro $(url)
$tellraw @s [{"text":"[guikit] ","color":"gold"},{"text":"Open link: ","color":"gray"},{"text":"$(url)","color":"aqua","underlined":true,"click_event":{"action":"open_url","url":"$(url)"}}]
