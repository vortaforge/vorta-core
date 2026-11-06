forceload add 1 1
setblock 1 0 1 minecraft:oak_sign{Text1:'{"text":""}'} replace
data modify storage vf_macro:string sign_payload set value {text:"",extra:[]}
data modify storage vf_macro:string sign_payload.extra set from storage vf_macro:string extra
data modify storage vf_macro:out sign_payload set from storage vf_macro:string sign_payload
data modify block 1 0 1 Text1 set value '{"text":"[VF Macro] multi-token: enable multi_exec 1b"}'
