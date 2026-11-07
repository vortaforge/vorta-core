# macroengine:core/internal/text/load
# Builds the lookup tables used by the text module (storage macroengine:text_map).
# Idempotent; called from macroengine:setup.
data modify storage macroengine:text_map lower set value {"A":"a","B":"b","C":"c","D":"d","E":"e","F":"f","G":"g","H":"h","I":"i","J":"j","K":"k","L":"l","M":"m","N":"n","O":"o","P":"p","Q":"q","R":"r","S":"s","T":"t","U":"u","V":"v","W":"w","X":"x","Y":"y","Z":"z"}
data modify storage macroengine:text_map upper set value {"a":"A","b":"B","c":"C","d":"D","e":"E","f":"F","g":"G","h":"H","i":"I","j":"J","k":"K","l":"L","m":"M","n":"N","o":"O","p":"P","q":"Q","r":"R","s":"S","t":"T","u":"U","v":"V","w":"W","x":"X","y":"Y","z":"Z"}
data modify storage macroengine:text_map digit set value {"0":1b,"1":1b,"2":1b,"3":1b,"4":1b,"5":1b,"6":1b,"7":1b,"8":1b,"9":1b}
data modify storage macroengine:text_map deny_name set value {" ":1b,"'":1b,"{":1b,"}":1b,"[":1b,"]":1b,"(":1b,")":1b,"<":1b,">":1b,":":1b,";":1b,",":1b,"=":1b,"!":1b,"@":1b,"#":1b,"$":1b,"%":1b,"&":1b,"*":1b,"+":1b,"?":1b,"/":1b,"|":1b,"^":1b,"`":1b,"~":1b,"§":1b}
data modify storage macroengine:text_map deny_tag set value {" ":1b,"'":1b,"{":1b,"}":1b,"[":1b,"]":1b,":":1b,"§":1b,"|":1b,"^":1b,"<":1b,">":1b}
