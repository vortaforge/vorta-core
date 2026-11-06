# PUBLIC API — vf_macro:api/return/fail
# Simulates /return fail

scoreboard players set #vf_macro.returned vf_macro 1
data modify storage vf_macro:out return_value set value 0
data modify storage vf_macro:out return_success set value 0b
