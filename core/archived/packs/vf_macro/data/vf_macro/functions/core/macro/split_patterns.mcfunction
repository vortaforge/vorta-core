# Uses: internal.seg, internal.find, internal.new, internal.cur_key
# On match: appends left, new, right to out.resolved and sets seg_done=1

# --- $(name) ---
execute if score #vf_macro.seg_done vf_macro matches 0 if data storage vf_macro:internal {find:"$(name)"} if data storage vf_macro:internal {seg:"say Hello $(name)!"} run data modify storage vf_macro:out resolved append value "say Hello "
execute if score #vf_macro.seg_done vf_macro matches 0 if data storage vf_macro:internal {find:"$(name)"} if data storage vf_macro:internal {seg:"say Hello $(name)!"} run data modify storage vf_macro:out resolved append from storage vf_macro:internal new
execute if score #vf_macro.seg_done vf_macro matches 0 if data storage vf_macro:internal {find:"$(name)"} if data storage vf_macro:internal {seg:"say Hello $(name)!"} run data modify storage vf_macro:out resolved append value "!"
execute if score #vf_macro.seg_done vf_macro matches 0 if data storage vf_macro:internal {find:"$(name)"} if data storage vf_macro:internal {seg:"say Hello $(name)!"} run scoreboard players set #vf_macro.seg_done vf_macro 1

execute if score #vf_macro.seg_done vf_macro matches 0 if data storage vf_macro:internal {find:"$(name)"} if data storage vf_macro:internal {seg:"say Hello $(name)"} run data modify storage vf_macro:out resolved append value "say Hello "
execute if score #vf_macro.seg_done vf_macro matches 0 if data storage vf_macro:internal {find:"$(name)"} if data storage vf_macro:internal {seg:"say Hello $(name)"} run data modify storage vf_macro:out resolved append from storage vf_macro:internal new
execute if score #vf_macro.seg_done vf_macro matches 0 if data storage vf_macro:internal {find:"$(name)"} if data storage vf_macro:internal {seg:"say Hello $(name)"} run scoreboard players set #vf_macro.seg_done vf_macro 1

execute if score #vf_macro.seg_done vf_macro matches 0 if data storage vf_macro:internal {find:"$(name)"} if data storage vf_macro:internal {seg:"Hello $(name)!"} run data modify storage vf_macro:out resolved append value "Hello "
execute if score #vf_macro.seg_done vf_macro matches 0 if data storage vf_macro:internal {find:"$(name)"} if data storage vf_macro:internal {seg:"Hello $(name)!"} run data modify storage vf_macro:out resolved append from storage vf_macro:internal new
execute if score #vf_macro.seg_done vf_macro matches 0 if data storage vf_macro:internal {find:"$(name)"} if data storage vf_macro:internal {seg:"Hello $(name)!"} run data modify storage vf_macro:out resolved append value "!"
execute if score #vf_macro.seg_done vf_macro matches 0 if data storage vf_macro:internal {find:"$(name)"} if data storage vf_macro:internal {seg:"Hello $(name)!"} run scoreboard players set #vf_macro.seg_done vf_macro 1

# say $(name)
execute if score #vf_macro.seg_done vf_macro matches 0 if data storage vf_macro:internal {find:"$(name)"} if data storage vf_macro:internal {seg:"say $(name)"} run data modify storage vf_macro:out resolved append value "say "
execute if score #vf_macro.seg_done vf_macro matches 0 if data storage vf_macro:internal {find:"$(name)"} if data storage vf_macro:internal {seg:"say $(name)"} run data modify storage vf_macro:out resolved append from storage vf_macro:internal new
execute if score #vf_macro.seg_done vf_macro matches 0 if data storage vf_macro:internal {find:"$(name)"} if data storage vf_macro:internal {seg:"say $(name)"} run scoreboard players set #vf_macro.seg_done vf_macro 1

# --- $(msg) ---
execute if score #vf_macro.seg_done vf_macro matches 0 if data storage vf_macro:internal {find:"$(msg)"} if data storage vf_macro:internal {seg:"say $(msg)"} run data modify storage vf_macro:out resolved append value "say "
execute if score #vf_macro.seg_done vf_macro matches 0 if data storage vf_macro:internal {find:"$(msg)"} if data storage vf_macro:internal {seg:"say $(msg)"} run data modify storage vf_macro:out resolved append from storage vf_macro:internal new
execute if score #vf_macro.seg_done vf_macro matches 0 if data storage vf_macro:internal {find:"$(msg)"} if data storage vf_macro:internal {seg:"say $(msg)"} run scoreboard players set #vf_macro.seg_done vf_macro 1

# --- $(player) ---
execute if score #vf_macro.seg_done vf_macro matches 0 if data storage vf_macro:internal {find:"$(player)"} if data storage vf_macro:internal {seg:"say Hello $(player)!"} run data modify storage vf_macro:out resolved append value "say Hello "
execute if score #vf_macro.seg_done vf_macro matches 0 if data storage vf_macro:internal {find:"$(player)"} if data storage vf_macro:internal {seg:"say Hello $(player)!"} run data modify storage vf_macro:out resolved append from storage vf_macro:internal new
execute if score #vf_macro.seg_done vf_macro matches 0 if data storage vf_macro:internal {find:"$(player)"} if data storage vf_macro:internal {seg:"say Hello $(player)!"} run data modify storage vf_macro:out resolved append value "!"
execute if score #vf_macro.seg_done vf_macro matches 0 if data storage vf_macro:internal {find:"$(player)"} if data storage vf_macro:internal {seg:"say Hello $(player)!"} run scoreboard players set #vf_macro.seg_done vf_macro 1

# --- generic: "say $(key)" for amount/value/text/count ---
execute if score #vf_macro.seg_done vf_macro matches 0 if data storage vf_macro:internal {seg:"say $(amount)"} if data storage vf_macro:internal {find:"$(amount)"} run data modify storage vf_macro:out resolved append value "say "
execute if score #vf_macro.seg_done vf_macro matches 0 if data storage vf_macro:internal {seg:"say $(amount)"} if data storage vf_macro:internal {find:"$(amount)"} run data modify storage vf_macro:out resolved append from storage vf_macro:internal new
execute if score #vf_macro.seg_done vf_macro matches 0 if data storage vf_macro:internal {seg:"say $(amount)"} if data storage vf_macro:internal {find:"$(amount)"} run scoreboard players set #vf_macro.seg_done vf_macro 1
