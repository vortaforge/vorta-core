execute if data storage vf_macro:in source run data modify storage vf_macro:args {} merge from storage vf_macro:in source
execute if data storage vf_macro:in template run function vf_macro:api/macro/template
execute if data storage vf_macro:in parts run function vf_macro:api/macro/parts
execute unless data storage vf_macro:in template unless data storage vf_macro:in parts if data storage vf_macro:in Command run function vf_macro:api/macro/run
