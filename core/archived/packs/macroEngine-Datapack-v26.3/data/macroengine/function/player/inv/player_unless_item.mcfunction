$execute as @a[name=$(player),limit=1] at @s unless items entity @s contents $(item)[minecraft:custom_data=$(customData)] run $(invoke)
