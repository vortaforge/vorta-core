# macroengine:core/internal/api/store/_find_tpl [INTERNAL]
# Language fallback order: in.lang, the executor's own "lang", global "lang", then "en_us".
data modify storage macroengine:store tmp.langs set value []
execute if data storage macroengine:store in.lang run data modify storage macroengine:store tmp.langs append from storage macroengine:store in.lang
execute if entity @s[type=player] run function macroengine:core/internal/api/store/_plang
execute if data storage macroengine:store g.lang run data modify storage macroengine:store tmp.langs append from storage macroengine:store g.lang
execute if data storage macroengine:engine config.store_default_lang run data modify storage macroengine:store tmp.langs append from storage macroengine:engine config.store_default_lang
execute unless data storage macroengine:engine config.store_default_lang run data modify storage macroengine:store tmp.langs append value "en_us"
function macroengine:core/internal/api/store/_find_loop
