# Text UI module (`tui/`)

Small helpers that print formatted lines, headers, dividers and clickable buttons to **the executor (`@s`)**.
Address another player with `execute as <player> run function macroengine:tui/...`.

All text is read from **storage** (`macroengine:tui in`) and rendered with `api/store/render`, so `%tokens%`
work and no text is ever pasted into a command or JSON string. The only macro argument in the module is the
function id of a button, and it is checked with `systems/validate/function_id` first.

Every function honours the load gate and the consent gate like the rest of the pack. The module has no
`config` switch of its own.

## Input

`macroengine:tui in`:

| Key | Used by | Meaning |
|---|---|---|
| `text` | `line`, `header` | string with `%tokens%` |
| `label` | `button` | button label, string with `%tokens%` |
| `fn` | `button` | function id `namespace:path` (tags and arguments are refused) |
| `hover` | `button` | hover text, default `Click to run` |
| `style` | `line` | `info`, `warn`, `error` or `ok`; omitted = plain white |
| `args` | all | compound for `%name%` tokens (see [store.md](store.md)) |

## Functions

| Function | Result |
|---|---|
| `tui/line` | one line, optionally prefixed by `style` |
| `tui/header` | `═══════ text ═══════` bar |
| `tui/divider` | horizontal rule, no input |
| `tui/button` | clickable `[ label ]` that runs `/function <fn>` |

All return `1` when something was sent and `0` otherwise (missing input, invalid template, invalid `fn`).

## Example

```mcfunction
data modify storage macroengine:tui in set value {text:"Shop menu"}
function macroengine:tui/header
data modify storage macroengine:tui in set value {text:"You have %score:coins% coins", style:"info"}
function macroengine:tui/line
data modify storage macroengine:tui in set value {label:"Buy sword", fn:"mypack:shop/buy_sword", hover:"Costs 10 coins"}
function macroengine:tui/button
function macroengine:tui/divider
```

## Notes

- A click runs `/function <fn>` **as the player**, so the player needs permission for `/function`
  (the buttons of `api/toggle/show` behave the same way). The target function should do its own checks.
- `in` is not cleared between calls; set it again (or `data remove storage macroengine:tui in`) for each call.
- Internals live in `core/internal/tui/` and use the storage keys `t`, `l`, `h` and `b` of `macroengine:tui`.
