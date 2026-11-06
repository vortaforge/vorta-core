# PUBLIC API — vf_macro:api/return/success
# Simulates /return 1 (or bare /return) for pre-1.20.2.
# Sets the returned flag so callers can early-exit.

scoreboard players set #vf_macro.returned vf_macro 1
data modify storage vf_macro:out return_value set value 1
data modify storage vf_macro:out return_success set value 1b
