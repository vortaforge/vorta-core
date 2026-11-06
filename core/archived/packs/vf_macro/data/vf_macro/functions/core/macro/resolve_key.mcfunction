# Private — resolve current part (pure 1.16–1.20)
# {key:"name"}           → lookup vf_macro:args.name
# {key:"any", value:"v"} → use value directly

scoreboard players set #vf_macro.key_found vf_macro 0

# 1) Inline value (highest priority)
execute if data storage vf_macro:internal current.value run data modify storage vf_macro:out resolved append from storage vf_macro:internal current.value
execute if data storage vf_macro:internal current.value run scoreboard players set #vf_macro.key_found vf_macro 1

# 2) Whitelist lookup – check current.key directly (avoids fragile {keyname:...} match)
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal current{key:"name"} if data storage vf_macro:args name run data modify storage vf_macro:out resolved append from storage vf_macro:args name
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal current{key:"name"} if data storage vf_macro:args name run scoreboard players set #vf_macro.key_found vf_macro 1

execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal current{key:"amount"} if data storage vf_macro:args amount run data modify storage vf_macro:out resolved append from storage vf_macro:args amount
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal current{key:"amount"} if data storage vf_macro:args amount run scoreboard players set #vf_macro.key_found vf_macro 1

execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal current{key:"player"} if data storage vf_macro:args player run data modify storage vf_macro:out resolved append from storage vf_macro:args player
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal current{key:"player"} if data storage vf_macro:args player run scoreboard players set #vf_macro.key_found vf_macro 1

execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal current{key:"value"} if data storage vf_macro:args value run data modify storage vf_macro:out resolved append from storage vf_macro:args value
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal current{key:"value"} if data storage vf_macro:args value run scoreboard players set #vf_macro.key_found vf_macro 1

execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal current{key:"msg"} if data storage vf_macro:args msg run data modify storage vf_macro:out resolved append from storage vf_macro:args msg
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal current{key:"msg"} if data storage vf_macro:args msg run scoreboard players set #vf_macro.key_found vf_macro 1

execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal current{key:"text"} if data storage vf_macro:args text run data modify storage vf_macro:out resolved append from storage vf_macro:args text
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal current{key:"text"} if data storage vf_macro:args text run scoreboard players set #vf_macro.key_found vf_macro 1

execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal current{key:"count"} if data storage vf_macro:args count run data modify storage vf_macro:out resolved append from storage vf_macro:args count
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal current{key:"count"} if data storage vf_macro:args count run scoreboard players set #vf_macro.key_found vf_macro 1

execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal current{key:"target"} if data storage vf_macro:args target run data modify storage vf_macro:out resolved append from storage vf_macro:args target
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal current{key:"target"} if data storage vf_macro:args target run scoreboard players set #vf_macro.key_found vf_macro 1

execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal current{key:"id"} if data storage vf_macro:args id run data modify storage vf_macro:out resolved append from storage vf_macro:args id
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal current{key:"id"} if data storage vf_macro:args id run scoreboard players set #vf_macro.key_found vf_macro 1

execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal current{key:"x"} if data storage vf_macro:args x run data modify storage vf_macro:out resolved append from storage vf_macro:args x
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal current{key:"x"} if data storage vf_macro:args x run scoreboard players set #vf_macro.key_found vf_macro 1

execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal current{key:"y"} if data storage vf_macro:args y run data modify storage vf_macro:out resolved append from storage vf_macro:args y
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal current{key:"y"} if data storage vf_macro:args y run scoreboard players set #vf_macro.key_found vf_macro 1

execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal current{key:"z"} if data storage vf_macro:args z run data modify storage vf_macro:out resolved append from storage vf_macro:args z
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal current{key:"z"} if data storage vf_macro:args z run scoreboard players set #vf_macro.key_found vf_macro 1

execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal current{key:"pos"} if data storage vf_macro:args pos run data modify storage vf_macro:out resolved append from storage vf_macro:args pos
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal current{key:"pos"} if data storage vf_macro:args pos run scoreboard players set #vf_macro.key_found vf_macro 1

execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal current{key:"cmd"} if data storage vf_macro:args cmd run data modify storage vf_macro:out resolved append from storage vf_macro:args cmd
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal current{key:"cmd"} if data storage vf_macro:args cmd run scoreboard players set #vf_macro.key_found vf_macro 1

execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal current{key:"func"} if data storage vf_macro:args func run data modify storage vf_macro:out resolved append from storage vf_macro:args func
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal current{key:"func"} if data storage vf_macro:args func run scoreboard players set #vf_macro.key_found vf_macro 1

execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal current{key:"selector"} if data storage vf_macro:args selector run data modify storage vf_macro:out resolved append from storage vf_macro:args selector
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal current{key:"selector"} if data storage vf_macro:args selector run scoreboard players set #vf_macro.key_found vf_macro 1

# 3) Missing → visible marker so you can see the skip
execute if score #vf_macro.key_found vf_macro matches 0 run data modify storage vf_macro:out resolved append value "$(missing)"
