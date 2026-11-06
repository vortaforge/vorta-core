# Title module (`api/title`)

Two generations live side by side. The older functions (`show`, `show_raw`, `broadcast`, `actionbar`)
build their text from macro arguments and are unchanged. The `*_p` functions below read **storage**,
so any text is safe, and they understand `%tokens%` rendered by `api/store/render` (see [store.md](store.md)).

## Input

`macroengine:title in`, all keys optional:

| Key | Meaning | Default |
|---|---|---|
| `title` | string with `%tokens%` | empty |
| `subtitle` | string with `%tokens%` | empty |
| `fade_in` / `stay` / `fade_out` | ticks | 10 / 70 / 20 |
| `text` | action bar text (`actionbar_*` functions only) | empty |

`show_p` fills the missing timing keys in storage, so they stay set for later calls.

## Functions

| Function | Macro args | Who sees it |
|---|---|---|
| `show_p` | | the executor (`@s`) |
| `show_to_p` | `player` | one named player |
| `broadcast_p` | | every online player |
| `show_team_p` | `team` | members of a team |
| `show_tag_p` | `tag` | players with a tag |
| `show_area_p` | `radius` | players within `radius` of the position the function runs at |
| `actionbar_p` | | the executor |
| `actionbar_all_p` | | every online player |
| `actionbar_tag_p` | `tag` | players with a tag |
| `times` | `player`, `fade_in`, `stay`, `fade_out` | sets timing only |
| `clear` / `reset` | `player` | clears the title / also resets timing |

Tokens resolve **per viewer** in the "all", team, tag and area variants, because each viewer
runs the function as themselves.

## Examples

```mcfunction
data modify storage macroengine:title in set value {title:"Welcome %player%",subtitle:"Coins: %score:coins%"}
function macroengine:api/title/show_p

# everyone, each with their own name
function macroengine:api/title/broadcast_p

# a team, a tag, an area
function macroengine:api/title/show_team_p {team:"red"}
function macroengine:api/title/show_tag_p {tag:"vip"}
execute positioned 0 64 0 run function macroengine:api/title/show_area_p {radius:32}

# action bar with live values
data modify storage macroengine:title in set value {text:"HP %health% | Lv %xp_level%"}
function macroengine:api/title/actionbar_all_p

# another player as the executor
execute as Steve run function macroengine:api/title/show_p
```

## Which one to use

* Plain, fixed text from a command: `show` / `broadcast`.
* Hand-written JSON components (gradients, translate): `show_raw`.
* Text that contains user input or tokens: the `*_p` functions.
