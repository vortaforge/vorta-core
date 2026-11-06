# Display multi-part result – most reliable form on 1.16–1.20
# tellraw_list is a list of {"text":"..."} compounds
execute if data storage vf_macro:out tellraw_list run tellraw @a {"nbt":"tellraw_list","storage":"vf_macro:out","interpret":true}
