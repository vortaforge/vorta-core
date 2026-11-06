# Runtime config (`core/config/*`)

Every behaviour knob of the pack is a key in `macroengine:engine config`, created with its default by
`config.mcfunction`. **Every key below changes behaviour**: it is read by the code named in its row, not
just stored. Values are validated against a schema (`macroengine:engine config_schema`), so `core/config/set`
clamps numbers to the listed range and refuses unknown keys and unsafe strings.

```mcfunction
data modify storage macroengine:engine config_in set value {key:"hud_rate",value:5}
function macroengine:core/config/set          # validated, clamped, applied at once

data modify storage macroengine:engine config_in set value {key:"module_store",value:0b}
function macroengine:core/config/set          # switches the whole api/store module off

data modify storage macroengine:engine config_in set value {key:"hud_rate"}
function macroengine:core/config/get          # macroengine:output result
function macroengine:core/config/list         # prints everything to @s
function macroengine:core/config/reset        # defaults for every key
```

| Function | Input | Result |
|---|---|---|
| `core/config/set` | `config_in {key, value}` | applies; returns 1, or 0 for an unknown key, a bad value or an unsafe string |
| `core/config/get` | `config_in.key` | `macroengine:output result`; returns 1 / 0 |
| `core/config/apply` | none | copies the config to the scores and storage the engine reads |
| `core/config/reset` | none | restores every default and applies it |
| `core/config/list` | none | prints the config to `@s` |
| `core/config/ensure` | none | creates and applies missing keys; called every tick by `core/tick` (one revision check) |

## Modules

Public functions of a disabled module return 0 without doing anything. Tick scans of `hook`, `geo`, `interaction`, `wand` and `perm` stop too. A module that other modules call (`store` is used by `title`, `log` by many) makes its callers fail softly. `validate`, `toggle`, `flag` and `core/*` cannot be disabled: the safety checks and the config itself depend on them. The six modules that had `api/toggle/<name>/true|false` before (`cb`, `geo`, `hook`, `interaction`, `perm`, `wand`) keep those functions; they now write this config.

| Key | Type | Default | Range | Effect |
|---|---|---|---|---|
| `module_cb` | bool | `1b` | 0b / 1b | api/cb/*: 0b makes every public function return 0 |
| `module_cmd` | bool | `1b` | 0b / 1b | api/cmd/*: 0b makes every public function return 0 |
| `module_color` | bool | `1b` | 0b / 1b | api/color/*: 0b makes every public function return 0 |
| `module_gamerule` | bool | `1b` | 0b / 1b | api/gamerule/*: 0b makes every public function return 0 |
| `module_interaction` | bool | `1b` | 0b / 1b | api/interaction/*: 0b makes every public function return 0 |
| `module_item` | bool | `1b` | 0b / 1b | api/item/*: 0b makes every public function return 0 |
| `module_macro` | bool | `1b` | 0b / 1b | api/macro/*: 0b makes every public function return 0 |
| `module_perm` | bool | `1b` | 0b / 1b | api/perm/*: 0b makes every public function return 0 |
| `module_store` | bool | `1b` | 0b / 1b | api/store/*: 0b makes every public function return 0 |
| `module_title` | bool | `1b` | 0b / 1b | api/title/*: 0b makes every public function return 0 |
| `module_trigger` | bool | `1b` | 0b / 1b | api/trigger/*: 0b makes every public function return 0 |
| `module_wand` | bool | `1b` | 0b / 1b | api/wand/*: 0b makes every public function return 0 |
| `module_block` | bool | `1b` | 0b / 1b | api/block/*: 0b makes every public function return 0 (`api/toggle/block/true\|false` writes this key) |
| `module_container` | bool | `1b` | 0b / 1b | api/container/*: 0b makes every public function return 0 (`api/toggle/container/true\|false` writes this key) |
| `module_audit` | bool | `1b` | 0b / 1b | systems/audit/*: 0b makes every public function return 0 |
| `module_geo` | bool | `1b` | 0b / 1b | systems/geo/*: 0b makes every public function return 0 |
| `module_hook` | bool | `1b` | 0b / 1b | systems/hook/*: 0b makes every public function return 0 |
| `module_log` | bool | `1b` | 0b / 1b | systems/log/*: 0b makes every public function return 0 |
| `module_logic` | bool | `1b` | 0b / 1b | systems/logic/*: 0b makes every public function return 0 |
| `module_math` | bool | `1b` | 0b / 1b | systems/math/*: 0b makes every public function return 0 |
| `module_rate_limit` | bool | `1b` | 0b / 1b | systems/rate_limit/*: 0b makes every public function return 0 |
| `module_rng` | bool | `1b` | 0b / 1b | systems/rng/*: 0b makes every public function return 0 |
| `module_sound` | bool | `1b` | 0b / 1b | systems/sound/*: 0b makes every public function return 0 |
| `module_string` | bool | `1b` | 0b / 1b | systems/string/*: 0b makes every public function return 0 |
| `module_text` | bool | `1b` | 0b / 1b | systems/text/*: 0b makes every public function return 0 |
| `module_uuid` | bool | `1b` | 0b / 1b | systems/uuid/*: 0b makes every public function return 0 |

## Tick systems

`systems/flag/toggle_system {system:"hud"}` flips the matching key (the old version flipped a score twice and never changed anything).

| Key | Type | Default | Range | Effect |
|---|---|---|---|---|
| `sys_time` | bool | `1b` | 0b / 1b | tick system "time": epoch and tick counters |
| `sys_player` | bool | `1b` | 0b / 1b | tick system "player": trigger, interaction, perm, wand, hook and freeze scans |
| `sys_queue` | bool | `1b` | 0b / 1b | tick system "queue": work queue and cb queue |
| `sys_hud` | bool | `1b` | 0b / 1b | tick system "hud": HUD systems (progress bar) |
| `sys_admin` | bool | `1b` | 0b / 1b | tick system "admin": admin triggers and region watch |

## Tick rates

| Key | Type | Default | Range | Effect |
|---|---|---|---|---|
| `tick_rate` | int | `1` | 1 - 1200 | engine tick runs once every N game ticks |
| `hud_rate` | int | `2` | 1 - 1200 | hud systems run once every N engine ticks |
| `admin_rate` | int | `4` | 1 - 1200 | admin systems run once every N engine ticks |

## Handlers

`hook_interval` above 1 can miss edge events that are only visible for one tick (death/respawn and sneak start); wand clicks, interaction hits and score based hooks are kept until processed, so they are only delayed.

| Key | Type | Default | Range | Effect |
|---|---|---|---|---|
| `hook_interval` | int | `1` | 1 - 1200 | hook event scan runs once every N engine ticks |
| `geo_interval` | int | `1` | 1 - 1200 | region watch scan runs once every N engine ticks |
| `interaction_interval` | int | `1` | 1 - 1200 | interaction entity scan runs once every N engine ticks |
| `wand_interval` | int | `1` | 1 - 1200 | wand right-click scan runs once every N engine ticks |
| `perm_trigger_interval` | int | `1` | 1 - 1200 | perm trigger scan runs once every N engine ticks |
| `queue_max_depth` | int | `256` | 1 - 4096 | work queue entries processed per tick |

## Core

| Key | Type | Default | Range | Effect |
|---|---|---|---|---|
| `log_level` | int | `3` | 0 - 4 | 0 off, 1 error, 2 warn, 3 info, 4 debug |
| `reload_warn` | bool | `1b` | 0b / 1b | warn online players on /reload when data would be lost |
| `validate_max_name` | int | `64` | 8 - 256 | max length of names that go into macro lines (systems/validate/safe_name) |

## Store (templates)

`api/store/render` returns 0 when a template is longer than `store_max_template` or has more tokens than `store_max_tokens`. Disabled tokens are treated like unknown ones.

| Key | Type | Default | Range | Effect |
|---|---|---|---|---|
| `store_default_lang` | str | `"en_us"` | max 16 chars | last-resort language when a template is looked up |
| `store_max_template` | int | `8192` | 16 - 32767 | longest template (characters) api/store/render accepts |
| `store_max_tokens` | int | `128` | 1 - 1024 | most %tokens% one template may contain |
| `store_tok_score` | bool | `1b` | 0b / 1b | token enabled: %score:obj% |
| `store_tok_player` | bool | `1b` | 0b / 1b | token enabled: %player% and %name% |
| `store_tok_entity` | bool | `1b` | 0b / 1b | token enabled: %health% %food% %xp_level% %dimension% |
| `store_tok_global` | bool | `1b` | 0b / 1b | token enabled: %g:name% |
| `store_tok_pvar` | bool | `1b` | 0b / 1b | token enabled: %p:name% |
| `store_tok_args` | bool | `1b` | 0b / 1b | token enabled: %name% from in.args |
| `store_keep_unknown` | bool | `1b` | 0b / 1b | 1b keeps an unresolved %token% as written, 0b replaces it with nothing |

## Title

| Key | Type | Default | Range | Effect |
|---|---|---|---|---|
| `title_fade_in` | int | `10` | 0 - 1200 | default fade-in ticks for api/title/show_p |
| `title_stay` | int | `70` | 0 - 72000 | default stay ticks for api/title/show_p |
| `title_fade_out` | int | `20` | 0 - 1200 | default fade-out ticks for api/title/show_p |

## Dynamic commands (stored command strings)

Everything that macro-executes a command *string from storage* (the queue, hooks, wands, triggers,
`multi_cmd`, `once_cmd`, region watchers and the command-block runners) is gated by
`macroengine:systems/cmd_gate/check`; the `api/cmd/*` string runners read the same switch.
Full contract, blocklist and permission examples: [cmd_gate.md](cmd_gate.md).

| Key | Type | Default | Range | Effect |
|---|---|---|---|---|
| `dynamic_cmd` | bool | `0b` | 0b / 1b | master switch for stored-string command execution; 0b makes every gated executor return 0 |
| `dynamic_cmd_max_len` | int | `256` | 1 - 4096 | longest command string the gate accepts |

## Permissions

Full description, switches and examples: [perm.md](perm.md).

| Key | Type | Default | Range | Effect |
|---|---|---|---|---|
| `perm_enforce` | bool | value of `perm_default` (ships `1b`) | 0b / 1b | 0b makes `api/perm/require` and `api/perm/check` pass for everybody; `systems/cmd_gate` ignores this switch |
| `perm_cmd` | bool | `0b` | 0b / 1b | 1b makes every `api/cmd/<name>` wrapper also need the permission `cmd.<name>` (only while `perm_enforce` is 1b) |

`perm_default` is not part of `config` on purpose, so `core/config/reset` keeps it: it is the value
`perm_enforce` gets when it is created or reset (`api/toggle/perm/default_on|default_off`).

## Not configurable (on purpose)

- `systems/validate/safe_name` rules other than the length limit, and the macro-injection guards in `api/store`: turning them off would let untrusted text into commands.
- Runtime identifiers (`#vortacraftmc.*` fake players, `macroengine:*` storage names): renaming them breaks existing worlds.
- The `macroengine:engine security.multi_type_allowlist` field has no code that reads it, so it is not a config key.
