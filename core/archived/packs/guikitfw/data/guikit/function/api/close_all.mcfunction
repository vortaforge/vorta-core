# Close every open guikit menu on the server
execute as @a[scores={guikit.timer=1..}] at @s run function guikit:api/close
