# macroengine:api/store/text/define
# Stores a message template for one language.
#
# INPUT  macroengine:store in.name   (string) template id, e.g. "shop.welcome"
#        macroengine:store in.lang   (string) language key, e.g. "en_us", "tr_tr"
#        macroengine:store in.value  (string) the template; see api/store/render for the % syntax
# RETURN 1 on success, 0 on invalid name/lang or missing value.
# Plain strings in, plain strings out. Nothing here ever builds a text component.
# Names are checked with systems/validate/safe_name while they are still data in storage,
# before they reach a macro line (see api/perm/require for the same pattern).
execute if data storage macroengine:engine modules{store:0b} run return 0
data remove storage macroengine:store tmp
execute unless data storage macroengine:store in.value run return 0
execute unless function macroengine:core/internal/api/store/_name run return 0
execute unless function macroengine:core/internal/api/store/_lang run return 0
return run function macroengine:core/internal/api/store/_t_define with storage macroengine:store tmp.k
