# Merge in.data into args (creates args if missing)
execute if data storage vf_macro:in data run data modify storage vf_macro:args {} merge from storage vf_macro:in data
