# vf_macro:string/resolve
# Input : storage vf_macro:string in.key  (string, e.g. "name")
# Output: storage vf_macro:string out
# Looks up vf_macro:args.<key>. Pure 1.16–1.20.

data remove storage vf_macro:string out
scoreboard players set #vf_macro.key_found vf_macro 0

execute if data storage vf_macro:string {in:{key:"name"}} if data storage vf_macro:args name run data modify storage vf_macro:string out set from storage vf_macro:args name
execute if data storage vf_macro:string {in:{key:"name"}} if data storage vf_macro:args name run scoreboard players set #vf_macro.key_found vf_macro 1

execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:string {in:{key:"amount"}} if data storage vf_macro:args amount run data modify storage vf_macro:string out set from storage vf_macro:args amount
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:string {in:{key:"amount"}} if data storage vf_macro:args amount run scoreboard players set #vf_macro.key_found vf_macro 1

execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:string {in:{key:"player"}} if data storage vf_macro:args player run data modify storage vf_macro:string out set from storage vf_macro:args player
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:string {in:{key:"player"}} if data storage vf_macro:args player run scoreboard players set #vf_macro.key_found vf_macro 1

execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:string {in:{key:"value"}} if data storage vf_macro:args value run data modify storage vf_macro:string out set from storage vf_macro:args value
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:string {in:{key:"value"}} if data storage vf_macro:args value run scoreboard players set #vf_macro.key_found vf_macro 1

execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:string {in:{key:"msg"}} if data storage vf_macro:args msg run data modify storage vf_macro:string out set from storage vf_macro:args msg
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:string {in:{key:"msg"}} if data storage vf_macro:args msg run scoreboard players set #vf_macro.key_found vf_macro 1

execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:string {in:{key:"text"}} if data storage vf_macro:args text run data modify storage vf_macro:string out set from storage vf_macro:args text
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:string {in:{key:"text"}} if data storage vf_macro:args text run scoreboard players set #vf_macro.key_found vf_macro 1

execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:string {in:{key:"count"}} if data storage vf_macro:args count run data modify storage vf_macro:string out set from storage vf_macro:args count
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:string {in:{key:"count"}} if data storage vf_macro:args count run scoreboard players set #vf_macro.key_found vf_macro 1

execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:string {in:{key:"target"}} if data storage vf_macro:args target run data modify storage vf_macro:string out set from storage vf_macro:args target
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:string {in:{key:"target"}} if data storage vf_macro:args target run scoreboard players set #vf_macro.key_found vf_macro 1

# Missing key → keep a visible marker
execute if score #vf_macro.key_found vf_macro matches 0 run data modify storage vf_macro:string out set value "$(?)"
