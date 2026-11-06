# Store module (`api/store/*`)

Storage-based variables, per-player values, raw NBT helpers and multilingual message templates.
This is the one module for storage work; it replaced `api/data/*` (now `api/store/nbt/*`) and
`api/placeholder/*` (removed). Values are **plain strings or numbers in command storage**; nothing
here builds a text component and nothing is sent to chat unless you call a `show` function.

All inputs go through `macroengine:store` (`in.*`), results come back in the same storage
(`out.*`) and, for `render`, also in `macroengine:output store.string`. Names are checked with
`systems/validate/safe_name` while they are still data, before they reach a macro line, so
untrusted text (chat, books, signs) cannot inject commands.

Names: 1-64 characters, letters/digits/`_`/`.`/`-`. A dot nests (`shop.price` is `g.shop.price`).
Use ASCII names; non-ASCII letters pass the check but may not work in an NBT path.

## Variables

| Function | Input (`in.`) | Output |
|---|---|---|
| `api/store/set` | `name`, `value` (any NBT) | return 1 / 0 |
| `api/store/default` | `name`, `value` (only if not set) | return 1 / 0 |
| `api/store/get` | `name` | `out.value`, return 1 / 0 |
| `api/store/has` | `name` | return 1 / 0 |
| `api/store/remove` | `name` | return 1 / 0 |
| `api/store/add` | `name`, `by` (int, default 1) | `out.value`, return = new value |
| `api/store/show` | `name` | `out.value` and a chat line for `@s`, return 1 / 0 |

`api/store/player/*` has the same functions. They act on the executor (`execute as <player> run ...`);
the key is derived from the player's UUID. Non-player executors get return 0.

```mcfunction
data modify storage macroengine:store in set value {name:"kills",by:1}
execute as @a[tag=winner] run function macroengine:api/store/player/add
```

`add` is for counters (ints). Do not use it on string values.

`get` only writes `out.value`; it never prints. To see a value in chat, call `show` (or `player/show` for
the executor's own value). It reads the value with an NBT text component (`"interpret": false`), so strings
appear as written and numbers, lists and compounds as SNBT. Nothing is stored as a text component.

```mcfunction
data modify storage macroengine:store in set value {name:"shop.price"}
function macroengine:api/store/show
# [MACROENGINE] shop.price = 100

data modify storage macroengine:store in set value {name:"coins"}
execute as @p run function macroengine:api/store/player/show
```

Or print `out.value` yourself after any `get`:

```mcfunction
tellraw @s {"storage":"macroengine:store","nbt":"out.value","interpret":false}
```

## Message templates

```mcfunction
# define once (per language)
data modify storage macroengine:store in set value {name:"shop.welcome",lang:"en_us",value:"Hi %player%, you have %p:coins% coins."}
function macroengine:api/store/text/define
data modify storage macroengine:store in set value {name:"shop.welcome",lang:"tr_tr",value:"Merhaba %player%, %p:coins% paran var."}
function macroengine:api/store/text/define

# use
data modify storage macroengine:store in set value {name:"shop.welcome"}
execute as @p run function macroengine:api/store/render
# -> macroengine:store out.string  (plain string)
```

Language order: `in.lang`, the executor's own `lang` (`api/store/player/set` with name `lang`), the global
`lang` (`api/store/set`), then `en_us`.

Tokens in a template: `%name%` (from `in.args`), `%g:name%`, `%p:name%`, `%score:objective%`, `%player%`,
`%health%`, `%food%`, `%xp_level%`, `%dimension%`, `%nl%`, `%%`. Unknown or unclosed tokens stay as written. Values are not parsed again. Compound and list
values are rejected (render returns 0) so raw NBT never leaks into a message.

You can also pass `in.template` instead of `in.name` to render a one-off string.

## Using the rendered string

`render` leaves a plain string in `macroengine:store out.string`. Nothing is printed. Choose what to do with it:

```mcfunction
# show it (the component only exists while the command runs)
tellraw @s {"storage":"macroengine:store","nbt":"out.string","interpret":false}
title @s actionbar {"storage":"macroengine:store","nbt":"out.string","interpret":false}

# keep it somewhere else
data modify storage mypack:data msg set from storage macroengine:store out.string
```

`api/store/convert` turns that string into more forms (all strings, ints, bytes or lists of strings):

| Output (`macroengine:store`) | Meaning |
|---|---|
| `conv.string` | the text as an NBT string |
| `conv.length` | number of characters |
| `conv.lines`, `conv.line_count` | list of lines (split on `%nl%`) and its length |
| `conv.safe` | `1b` when there is no quote, backslash, newline, carriage return or tab |
| `conv.macro` | `{text:"..."}`, only set when `conv.safe` is `1b`; pass with `with storage macroengine:store conv.macro` to a macro function that uses `$(text)` |

`api/store/render_all` renders once per online player (each render runs as that player) into
`macroengine:store all.entries`, a list of `{uuid:[I;...],string:"..."}`.

`api/title/show_p`, `actionbar_p` and the other `*_p` functions use `render` for their text
(they use `macroengine:store in`/`out` while they run).

## Raw NBT helpers (`api/store/nbt/*`)

Small helpers over any command storage. Every function takes `storage` (for example `"mypack:data"`)
and `path` (for example `"players.steve.kills"`) as **macro arguments**. Values travel through
`macroengine:store nbt.value` / `macroengine:store nbt.result`, so no SNBT ever needs escaping.

### Functions

| Function | Macro args | Value in | Result |
|---|---|---|---|
| `nbt/get` | `storage`, `path` | | `macroengine:store nbt.result`; returns 1 if the path exists, else 0 (result removed) |
| `nbt/set` | `storage`, `path` | `value` | overwrites the path |
| `set_default` | `storage`, `path` | `value` | writes only if the path is missing; returns 1 if it wrote, 0 if it existed |
| `append` | `storage`, `path` | `value` | appends to the list |
| `merge` | `storage`, `path` | `value` | merges a compound |
| `remove` | `storage`, `path` | | removes the path |
| `exists` | `storage`, `path` | | returns 1 / 0 |
| `count` | `storage`, `path` | | list length, string length or compound key count (0 if missing) |
| `copy` | `from`, `from_path`, `to`, `to_path` | | copies one value to another place |
| `add` | `storage`, `path`, `by` | | adds `by` (may be negative) to an int; a missing path counts as 0; returns the new value |
| `toggle` | `storage`, `path` | | flips a 0b/1b flag (missing becomes 1b); returns the new value |
| `pop` | `storage`, `path` | | removes the last list element into `result`; returns 1 if one was removed |
| `shift` | `storage`, `path` | | removes the first list element into `result` (queue); returns 1 if one was removed |

### Using the return value

`execute if function` does **not** accept macro arguments, so a macro function cannot be used as a
condition directly. Capture the return value with `execute store result` and test the score:

```mcfunction
execute store result score #r mypack.tmp run function macroengine:api/store/nbt/pop {storage:"mypack:data",path:"stack"}
execute if score #r mypack.tmp matches 1 run say popped
execute if score #r mypack.tmp matches 0 run say empty
```

Use your own objective (`mypack.tmp` here); `macroengine.tmp` is written by macroEngine's internals.

### Examples

```mcfunction
# initialise once, never overwrite live data
data modify storage macroengine:store nbt.value set value {kills:0,coins:100}
function macroengine:api/store/nbt/set_default {storage:"mypack:data",path:"players.steve"}

# counters and flags
function macroengine:api/store/nbt/add {storage:"mypack:data",path:"players.steve.kills",by:1}
function macroengine:api/store/nbt/toggle {storage:"mypack:data",path:"settings.pvp"}

# stack (pop) and queue (shift)
data modify storage mypack:data stack set value ["a","b","c"]
function macroengine:api/store/nbt/pop {storage:"mypack:data",path:"stack"}     # result = "c"
function macroengine:api/store/nbt/shift {storage:"mypack:data",path:"stack"}   # result = "a"

# read
function macroengine:api/store/nbt/get {storage:"mypack:data",path:"players.steve.coins"}
tellraw @s {"storage":"macroengine:store","nbt":"nbt.result"}
```

### Notes

* Arguments are developer input, like every macro API in the pack. Do not pass player-written
  text as `storage` or `path`.
* `pop` uses the negative index `[-1]`; verify it on your target version.
* `add` reads the value as an integer, so a float is truncated.
