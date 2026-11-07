# macroengine-modules

[![CI](https://github.com/vortaforge/macroengine-modules/actions/workflows/ci.yml/badge.svg)](https://github.com/vortaforge/macroengine-modules/actions/workflows/ci.yml)
[![Upstream canary](https://github.com/vortaforge/macroengine-modules/actions/workflows/upstream-canary.yml/badge.svg)](https://github.com/vortaforge/macroengine-modules/actions/workflows/upstream-canary.yml)

**macroEngine**, split from one data pack into **a core plus independent modules**.
The arrangement mirrors Fabric API: the core carries the engine, each module
attaches to it through *hook tags*, and the core never names a module.

```
me_core_module      the engine: every internal tree, load, tick, hook slots
me_cmd_module       command execution, freeze
me_player_module    player registry
me_wand_module      wand
...                 (17 more modules)
```

## Why this arrangement

The single-pack macroEngine was 1559 files, 1280 functions and 105 tags. Everything
lived in one namespace, so "let me remove this feature" meant hand-picking its
references out of more than 9000 of them. Split, removing a module is deleting
`packs/me_wand_module/`.

Two rules make that possible, and the verifier enforces both:

1. **The core never calls a module by name.** When the core needs a module it calls
   `function #me_core_module:hook/<slot>`. The module defines *the same tag id* in
   its own pack and adds itself; the game unions the two definitions.
2. **Every implementation lives in the core.** A module ships only its public
   surface and calls `me_core_module:core/internal/...`. It never ships a
   `core/internal/` tree of its own, and it never calls another module - two
   modules that need the same thing both call the core.

`gradlew check` verifies both. Deleting a module never breaks the pack, because
nothing outside that module ever names it.

## Id scheme

```
me_<module>_module:<function path>
```

The `api/` and `systems/` segments are **gone**: the namespace already says which
module, and the path says which feature. Old `macroengine:api/cmd/other/run` becomes
`me_cmd_module:cmd/other/run`. Zero collisions across all 1280 functions.

| Before | After |
|---|---|
| `macroengine:api/wand/give_custom` | `me_wand_module:wand/give_custom` |
| `macroengine:systems/logic/if_or` | `me_core_module:logic/if_or` |
| `macroengine:core/internal/text/split` | `me_core_module:core/internal/text/split` |
| `macroengine:api/player/init` | `me_core_module:core/internal/player/init` |
| `macroengine:api/store/render` | `me_core_module:core/internal/store/render` |

Note what the last two rows have in common: they are public `api/` functions that
the *core itself* calls, so they are infrastructure and moved into the core. The
module keeps a thin public function at its own id that forwards to them.

## Building

Each module is its own Gradle sub-project and produces its own jar:

```bash
export JAVA_HOME=/path/to/jdk25     # 26.3 requires Java 25

python3 tools/split.py --source <macroEngine-26.3 pack> --out . --in-place
./gradlew dist                      # build/dist/*.jar - 20 packs
./gradlew check                     # verify references, boundaries, hooks
./gradlew :me_cmd_module:dist       # one module's jar
```

`packs/` is generated output and is not committed. It deliberately sits **outside**
`build/`: `gradlew clean` deletes `build/`, and the packs are an *input* to the
build (they are its sub-projects), not an output of it. Putting them under `build/`
made `clean` delete the thing it was about to build.

### What is in a jar

Every jar is a **Fabric mod**, not a bare data pack:

```
me_cb_module-1.0.0.jar
├── fabric.mod.json                  mod manifest, id `macroengine-cb`
├── META-INF/jars/
│   └── macroengine-bootstrap.jar    the entry point, nested
├── pack.mcmeta                      data pack manifest (format 121)
└── data/me_cb_module/...            the pack itself
```

Install it by dropping it into the world's or profile's `mods/` folder.

**Fabric API is required.** The mod jar's `data/` tree is read by
`fabric-resource-loader`, which ships in Fabric API, not in the loader — this is
declared in every manifest's `depends`, so a missing Fabric API stops the game
with a readable message instead of loading 26 mods that silently do nothing.

The dependency names `fabric-api`, the umbrella id, not a specific module. The
module is `fabric-resource-loader-v0` as of Fabric API `0.165.2+26.3` (there is
also a `-v1`), and pinning a module name ties this project to something Fabric API
is free to retire.

The `data/` layout is identical to a `datapacks/` folder, so the same jar also
works there, with no mod loader at all.

### Which pack owns what

Every module can be installed on its own, next to the core. That is the property
the split exists for, and it constrains what may live where:

* **Core** holds the internals, the gates, load and tick, and the kernel services
  the engine itself calls at boot - `math`, `rng`, `log`, `string`, `color`,
  `validate`. A pack the engine cannot boot without is not a module.
* **Core also owns the extension points**: `tags/function/hook/*` and
  `tags/function/events/on_*`. Those are slots other modules publish into. A slot
  belongs to whoever defines it, so it stays in core even when the implementation
  behind it is a module.
* **A module never names another module.** Where one used to, the call goes
  through a core hook slot instead - `hook` firing an event calls
  `#me_core_module:hook/events_fire`, which the `events` module fills. Install
  `hook` without `events` and the slot is empty; the pack still loads.

`tools/test_module_removal.py` enforces it by deleting each module in turn and
re-verifying the rest. It found `me_core_module:loop` listing four `input`
functions unconditionally: with the input module absent the tag could fail to
load, so those values are now `required:false`.

### What is checked, and why

`tools/verify.py` answers "is the module graph sound": references resolve, no
module reaches into another's internals, core never names a module, no cycles.

`tools/check_refs.py` answers a narrower question that the graph check cannot: does
every `namespace:path` token in every pack point at something that exists? The split
renames ids from the source pack's namespace into one namespace per module. An id it
fails to recognise keeps the old namespace, where after the split nothing lives. The
game then either refuses the pack at load time -

```
Unbound values in registry ResourceKey[minecraft:root / minecraft:dialog]:
[macroengine:gate/confirm]
```

- or loads it and silently never runs the function.

Both happened. The second one is the dangerous one, so the checker fails on either.
It searches for bare `namespace:path` tokens rather than reusing the splitter's
patterns, precisely so that a missing pattern does not also blind the test.

`tools/test_check_refs.py` then breaks a copy of the output in each of the shapes
that have broken a real server - a dialog JSON key, `dialog show`, `execute if
predicate`, an SNBT `{func:"..."}` payload, `advancement revoke ... only`, and a
reference to an id that does not exist - and asserts the checker reports each one.
A checker that has never failed is not evidence, so it is tested against every way
it has already been wrong.

### The entry point

All 26 mods declare the same class,
`com.vortaforge.macroengine.runtime.MacroEngineEntry`, and that class lives in one
tiny jar nested inside each of them. It implements `net.fabricmc.api.ModInitializer`
and does nothing.

It has to implement the interface. A class that merely *exists* is not enough:
Fabric constructs the declared class and casts it, and a class that does not
implement `ModInitializer` fails the cast and stops the entire server, not just
that mod. That is a real failure this project shipped once.

One shared class rather than one per module, because 26 identical classes is 26
copies for a classloader to disambiguate, and a module jar is supposed to be
removable.

`fabric.mod.json` is generated twice, deliberately: `tools/split.py` writes one so
a pack directory is a valid mod source on its own, and `renderFabricMeta` in
`build.gradle` writes the one that ships, with the real version number. They are
compared field by field; the only difference is `version`, which split writes as
Fabric's `${file.jarVersion}` placeholder.

Every module declares `macroengine-core` as a dependency. **No module loads
without core**, but core loads and runs on its own — that is the whole point of
the split.

`gradlew dist` runs `tools/check_jars.py` afterwards and fails if any jar is not
loadable: no manifest, a manifest naming an entry point class that is not in the
jar, no `pack.mcmeta`, a duplicate mod id, or a module that forgot its core
dependency.

## Modules

| Module | Files | What it does |
|---|---:|---|
| `me_core_module` | 836 | engine, hook slots, load/tick, text and math services |
| `me_cmd_module` | 185 | command execution, freeze, multi_cmd |
| `me_player_module` | 181 | player registry, join/leave, name resolution |
| `me_store_module` | 71 | persistent key-value store |
| `me_perm_module` | 34 | permissions |
| `me_world_module` | 29 | world operations |
| `me_container_module` | 27 (+4 published) | container slot operations |
| `me_wand_module` | 26 | wand |
| `me_toggle_module` | 25 | on/off flags |
| `me_cb_module` | 23 | command block queue |
| `me_block_module` | 20 | block behaviour registry |
| `me_title_module` | 17 | title / actionbar |
| `me_item_module` | 16 | items |
| `me_interaction_module` | 16 | interaction scan |
| `me_color_module` | 13 | colour |
| `me_gamerule_module` | 13 | gamerules |
| `me_trigger_module` | 12 | trigger registry |
| `me_tui_module` | 8 | text UI |
| `me_macro_module` | 5 | macro helpers |
| `me_diagnostics_module` | 2 | diagnostics |

## Releases and CI

Releases are built from tags, not from a working directory:

```bash
git tag -a v1.0.0 -m "macroEngine modules 1.0.0"
git push origin v1.0.0
```

That builds all 20 packs, stamps every `pack.mcmeta` with the tag's version,
verifies the jars really carry it, and attaches them plus `SHA256SUMS.txt` to a
GitHub Release. A tag that already has a release is refused rather than
overwritten — people have downloaded those jars.

| Workflow | Runs | Does |
|---|---|---|
| `ci.yml` | every push and PR | split, verify, prove determinism, build |
| `release.yml` | on a `v*` tag | build, verify again, publish |
| `upstream-canary.yml` | daily | re-split against today's upstream pack |

The awkward thing all three have in common: `packs/` is not committed, so a fresh
checkout has nothing to build. Each job fetches the source pack from
`vortaforge/core` and re-runs the split. That is deliberate — the split is the
product, and a CI that only built previously generated output would never catch a
regression in the splitter itself.

`modules.json` **is** committed, unlike the packs it describes. It is the canary's
baseline: a split that silently loses a module or moves ids into the wrong pack
still passes verification, because the result is a perfectly consistent layout
that nobody reviewed. The only way to notice is to diff against the layout a human
looked at once — which is what `tools/check_shape.py` does.

Fork pull requests need no secrets: the source pack is public, so the token falls
back to the workflow's own. If `vortaforge/core` ever goes private, set
`SOURCE_READ_TOKEN`.

## Writing your own module

`docs/CORE.md` describes the hook contract; `docs/MODULE.md` walks through a new
module. In short: make a folder, use the `me_<name>_module` namespace, add your
value to the core's hook tag. You do not need to change a single line in the core.

## Tools

| File | Purpose |
|---|---|
| `tools/split.py` | splits the source pack: rewrites ids, emits hook tags |
| `tools/verify.py` | checks the split output (references, boundaries, cycles, hooks, pack.mcmeta) |

`split.py` never modifies its source. It refuses to clear an output directory that
looks like a project (a `.git`, or one of `src`/`tools`/`docs`); the project layout
is written with `--out . --in-place`, which clears only `packs/` and the two
manifests.

## Known limits

- `me_cmd_module:cmd/other/action_run` is a macro function: its target is built at
  run time from `$(type)` and cannot be resolved statically. It is listed in
  `MACRO_REFS.txt` and exempted in the verifier.
- `me_tui_module` writes `/function $(fn)` inside a tellraw `click_event`; same
  reason.
- Some tag references that already existed in the source pack (such as
  `#macroengine:internal/dispatch`) remain in the same shape in the split output.
  They are the source's own condition, not split damage.

## License

See `LICENSE`.
