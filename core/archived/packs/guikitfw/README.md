# guikit

Storage-authored GUI framework for Minecraft Java datapacks.  
Menus live in `storage guikit:lib`; the engine opens a per-player chest minecart, detects clicks (shift / left / drop), runs actions, and redraws every tick.

Inspired by the **guigen** runtime model (pid-bound entity containers, shift/left/drop click detection, vacuum + fill each tick).

**No bundled menus.** You register your own.

## Requirements

- Minecraft Java Edition with data pack format **121** (`min_format` and `max_format` are both 121 in `pack.mcmeta`; the same format as macroEngine v26.3). Other formats are not declared and are untested.
- Datapack load order: **guikit** before any pack that calls `register_menu`

## Install

1. Drop this folder (or release zip) into the world’s `datapacks/` directory  
2. `/reload`  
3. From another datapack (or a function):

```mcfunction
data modify storage guikit:in id set value "shop"
data modify storage guikit:in menu set value {name:"Shop",timer:900,pages:[{widgets:[...]}]}
function guikit:api/register_menu

data modify storage guikit:in menu set value "shop"
function guikit:api/open
```

## Player triggers (permission level 0)

| Trigger | Effect |
|---------|--------|
| `/trigger guikit.close` | Close your open menu |
| `/trigger guikit.last` | Reopen the last menu id for your pid |

There is **no** `/trigger guikit.open` and **no** `default_menu`.

## Menu schema

```snbt
{
  name: "Title",
  container: "chest_minecart",
  timer: 900,
  pages: [
    {
      on_enter: ["ns:on_page0"],
      widgets: [
        {
          slot: 13,
          kind: "give",
          id: "bread",
          item: "minecraft:bread",
          give: "minecraft:bread",
          count: 8,
          name: {text: "Bread", italic: false},
          lore: [{text: "Free", color: "gray", italic: false}]
        },
        {
          slot: 22,
          kind: "close",
          id: "close",
          item: "minecraft:barrier",
          name: {text: "Close", color: "red", italic: false}
        }
      ]
    }
  ]
}
```

### Widget `kind` values

| kind | Click | Role |
|------|-------|------|
| `label` / `separator` | no | Decoration (always restored) |
| `button` | yes | `msg` / `functions[]` |
| `give` | yes | `/give` from `give` + `count` |
| `close` | yes | Close menu |
| `nav` / `page` / `tab` | yes | Set page (`to` / `target_page`) |
| `toggle` | yes | Flip score `key` 0↔1 |
| `counter` / `add` | yes | Add `delta` to `key`, clamp min/max |
| `cycle` | yes | Advance `cycle.score` through `cycle.options` |
| `radio` | yes | Set `radio.score` to `radio.value` |
| `sound` | yes | Play UI note |
| `link` | yes | Show URL hint + close |
| `cmd` | yes | Run `functions[]` |
| `open` | yes | Open another menu id |
| `random` | yes | Weighted `random.rewards` |
| `progress` | no | Multi-slot bar from score |
| `indicator` / `meter` | partial | Hooks for extension |

Optional menu flags: `fill_empty`, `default_filler`, `on_open[]`, `on_close[]`, `container` (chest_minecart / *_chest_boat).

Optional per widget: `condition`, `costs[]`, `cooldown_ticks`, `success_message`.

Interactive widgets should set a stable `id` (used in `custom_data` and click matching).

## API

| Function | Purpose |
|----------|---------|
| `guikit:api/register_menu` | Input `guikit:in {id, menu}` → write lib + rebuild reg |
| `guikit:api/open` | Input `guikit:in {menu}` → open for `@s` |
| `guikit:api/close` | Close `@s` menu |
| `guikit:api/close_all` | Close every open menu |
| `guikit:api/refresh` | Force redraw |
| `guikit:help` | Chat summary |

## Config (`storage guikit:cfg`)

| Key | Default | Meaning |
|-----|---------|---------|
| `follow` | `1b` | Teleport cart to player each tick |
| `timer` | `900` | Default open duration (ticks) |
| `distance_close` | `8` | Used when `follow` is false |
| `container` | `chest_minecart` | Entity container type |
| `click_detection` | `["shift"]` | List of enabled click detectors. Shift-click detection always runs. Add `"left"` to also enable left-click detection (read by `internal/click/maybe_left` in the player tick). Drops are handled in the global tick and are not controlled by this key |
| `dynamic_cmd` | `0b` | Allow widget `commands[]` entries to run (`$execute as @s at @s run $(cmd)`). Off by default; `functions[]` is not affected. See "Trust boundary" |

## Runtime model (guigen-aligned)

1. **Open** — assign `guikit.pid`, summon invulnerable chest minecart, bind by pid  
2. **Tick (open players)** — bind → build widget queue from lib → **shift** (`clear` by id) → **left** (`unless items`, only when `click_detection` contains `"left"`) → vacuum inventory + **cursor** → redraw  
3. **Handler** — resolve widget → condition → cooldown → costs → `act/<kind>`  
4. **Global tick** — timer, triggers, cursor wipe for all players, drop cleanup  

`custom_data` shape: `{guikit:{widget:1, type, id, pack:"guikit", menu}}`.

## Extension tags

| Tag | When |
|-----|------|
| `#guikit:register` | After load / `rebuild_reg` |
| `#guikit:on_open` | After cart bound, before first draw |
| `#guikit:on_close` | Before cart killed |
| `#guikit:fill` | After page widgets placed |
| `#guikit:while_on` | Every tick, as each player with an open menu (`guikit.timer` 1..) |

Override `guikit:widget/<kind>` or `guikit:act/<kind>` in another pack to extend behaviour.

## Trust boundary

Menu definitions are code, not data. Widget `functions[]` entries are substituted into a macro line (`$function $(fn)`) and `commands[]` entries into `$execute as @s at @s run $(cmd)` (the latter only when `dynamic_cmd` is `1b`). guikit does not validate either string. Never build a menu, a `functions[]` entry or a `commands[]` entry from text a player typed (chat, signs, books, name tags, anvil renames). Register menus only from datapack code you control.

## Layout

```
data/guikit/function/
  api/           open close refresh register_menu close_all close_self
  core/          load tick player_tick
  runtime/       pid, last_*, put_menu, rebuild_reg, page_enter
  internal/      bind click container draw open text util
  widget/        one file per kind + _place
  act/           one file per kind + helpers
  cond/          condition dispatch
```

## Scores

| Objective | Role |
|-----------|------|
| `guikit.pid` | Per-player id |
| `guikit.uid` | Per-open session |
| `guikit.timer` | Open TTL |
| `guikit.page` | Page index |
| `guikit.click` | Click pipeline 0/1/2 |
| `guikit.cd` | Cooldown ticks |
| `guikit.last` / `guikit.close` | Triggers |

## Example consumer pack

See companion pack **ornek** / write your own `load` that calls `register_menu`, then:

```mcfunction
data modify storage guikit:in menu set value "shop"
function guikit:api/open
```

## License

Public domain (Unlicense) — see [LICENSE](LICENSE).

## Contributing

Issues and PRs welcome. Keep the framework **menu-free**; ship demos as separate packs.


## Block containers (kiosk)

```snbt
{
  name: "Kiosk",
  container: "barrel",
  pos: [100, 64, -20],
  timer: 1200,
  pages: [{widgets: [...]}]
}
```

Supported: `chest`, `trapped_chest`, `barrel`, `hopper`, `dropper`, `dispenser`, `ender_chest`, `large_chest`.  
Shared kiosk: block is removed only when the last player closes. Distance close default 8.
