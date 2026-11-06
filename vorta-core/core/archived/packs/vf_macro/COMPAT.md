# v1.9.0 — limits pushed (no ostr, no hardcoded keys)

## Tokens (recommended for placeholders)
```mcfunction
data modify storage vf_macro:in tokens set value [{text:"say hello"}]
function vf_macro:api/macro/template
```
```mcfunction
data modify storage vf_macro:in replace_list set value [{key:"msg",value:"say hi from token"}]
data modify storage vf_macro:in tokens set value [{key:"msg"}]
function vf_macro:api/macro/template
```

## Multi-token
- 1 token → engine (any command)
- 2+ tokens → `force_join`:
  - `multi_exec:1b` → each token runs as its **own full command** (sequential)
  - else → cannot invent plain string concat without macros/lib (reported clearly)

```mcfunction
data modify storage vf_macro:config multi_exec set value 1b
```

## Full-string placeholder
```mcfunction
data modify storage vf_macro:in template set value "$(cmd)"
data modify storage vf_macro:in replace_list set value [{find:"$(cmd)",value:"give @p diamond 1"}]
function vf_macro:api/macro/template
```

Physics of the game: arbitrary in-string concat on 1.16–1.20.1 without macros or a string library is not available. This pack pushes everything else.
