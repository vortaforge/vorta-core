# Writing a new module

This file describes how to add a module **by hand**, outside the pack splitter. The
fastest way to see the shape is to read an existing one: `packs/me_wand_module/` is
a good example (26 functions, one hook contribution).

## 1. Skeleton

```
me_shout_module/
├── pack.mcmeta
└── data/
    └── me_shout_module/
        ├── function/
        │   └── shout/
        │       └── send.mcfunction          # public surface - all you ship
        └── tags/                            # (optional) your own tags

# the implementation of `shout/send`, if it needs one, lives in the core pack:
#   me_core_module/data/me_core_module/function/core/internal/shout/send.mcfunction
```

`pack.mcmeta` (26.x form):

```json
{
  "pack": {
    "description": "me_shout_module (macroEngine 1.0.0)",
    "min_format": [121, 0],
    "max_format": [121, 0]
  }
}
```

## 2. Attach to the core

To join the core's tick hook, write this **in your own pack**:

```
data/me_core_module/tags/function/hook/tick.json
```

```json
{
  "replace": false,
  "values": [
    { "id": "me_shout_module:hook/tick", "required": false }
  ]
}
```

That is all. You did not touch a single file in the core, the core does not know
your name, and the core keeps working when you are removed.

> `replace: false` is **mandatory**. Write `true` and you delete the core's and
> every other module's contributions — the last writer wins, so one module silently
> switches off all the others.

## 3. Use the core's services

```mcfunction
# split text
data modify storage macroengine:input string set from storage me_shout:work line
data modify storage macroengine:input separator set value " "
data modify storage macroengine:input n set value 1
function me_core_module:text/split
data modify storage me_shout:work first set from storage macroengine:output string.result[0]
```

You **do** call `core/internal/...` - that is where the implementation is:

```mcfunction
function me_core_module:core/internal/shout/format
```

What you must never do is ship your own copy of it. There is exactly one
implementation of anything, it lives in `me_core_module`, and your pack contains
your public functions plus their hook contributions - no `core/` directory. A
module pack with a `core/internal/` tree is a second copy of core code that dies
with the module; `verify.py` rejects it as `module-internal`.

## 4. Use another module

Modules do not call each other. Two modules that both need the same thing both
call core:

```mcfunction
function me_core_module:core/internal/container/slot_set
```

The reason is removability. If `shout` calls `container`, deleting `container`
breaks `shout`. If both call core, deleting either one leaves the other running -
and the dependency graph stays a star instead of a mesh. `verify.py --graph`
enforces the star: every module points at core, core points at nothing.

## 5. Build

```bash
# generate the packs (only if you are splitting from a source pack)
python3 tools/split.py --source <pack> --out . --in-place

# your module's jar
./gradlew :me_shout_module:dist

# everything plus verification
./gradlew check dist
```

If you created a folder under `packs/` by hand, `settings.gradle` finds it on its
own (it scans the directory rather than hard-coding a list). But `split.py` rewrites
the whole `packs/` tree on every run, so a hand-made folder **is deleted** by the
next split. If you are writing a module meant to last, add it to the `MODULES` table
in `tools/split.py`, or keep the module outside `packs/` as its own project.

## 6. Verify

```bash
./gradlew check
```

If you see these:

| Message | Meaning |
|---|---|
| `dangling-reference` | there is a `function x:y` but `y` is defined in no pack |
| `module-internal` | you shipped a `core/internal/` tree inside your module |
| `private-access` | you called another module instead of core |
| `hooks` | the core calls a module by name (the core's fault, not yours) |
| `cycle` | the module graph has a cycle; usually two modules calling each other |
| `pack-layout` | missing `pack.mcmeta`, or an empty pack |

## 7. Document your published surface

Put a three-line `PUBLIC.md` in your module's repository: which ids are the
contract, which input storage they read, which output they write, what they return.
`verify.py` does not check this; the next person writing a module does.
