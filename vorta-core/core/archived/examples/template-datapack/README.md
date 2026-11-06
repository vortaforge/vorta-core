# template-datapack

A minimal, loadable starting point for a new datapack in this repository. Its
only content is the load/tick wiring; you replace the namespace and fill in the
two functions.

The previous version of this file contained a single empty `<div></div>` and
nothing else, which made the template - the first thing a new contributor
opens - the least documented directory in the repository.

## Layout

```
template-datapack/
├── pack.mcmeta
└── data/
    ├── minecraft/tags/function/
    │   ├── load.json      -> "#template:template/load"
    │   └── tick.json      -> "#template:template/tick"
    └── template/
        ├── function/template/
        │   ├── load.mcfunction
        │   └── tick.mcfunction
        └── tags/function/template/
            ├── load.json  -> "template:template/load"
            └── tick.json  -> "template:template/tick"
```

## The two-level tag indirection, and why it is there

`minecraft:load` does **not** point at a function. It points at a *tag*
(`#template:template/load`), which in turn contains the real function.

That extra hop is the point. Another pack can add its own function to
`#template:template/load` and run alongside this one, without either pack
having to edit the other's files or fight over `data/minecraft/tags/`. If you
do not need other packs to hook in, the indirection costs you one JSON file and
buys you nothing - collapse it and point `minecraft:load` straight at your
function.

## Using it

1. Copy the directory: `cp -r examples/template-datapack packs/<your-pack>`.
2. Rename the namespace: `template` -> your own (both the `data/<namespace>/`
   directory and the tag/function references inside the JSON files). Keep it
   lowercase and specific enough not to collide with another pack here or with
   a common third-party pack - see `NOTICE.md` on namespace isolation.
3. Write your code in `load.mcfunction` (runs once on `/reload` and world load)
   and `tick.mcfunction` (runs every tick).
4. Add the provenance watermark by running `python3 scripts/origin_watermarks.py --write`
   (it creates `packs/<your-pack>/data/<namespace>/function/_vc_origin.mcfunction`).
   `zipPacks` fails the build if a datapack under `packs/` is missing this
   provenance watermark; see `CONTRIBUTING.md`.
5. Set the format range in `pack.mcmeta` - see the note below.

## Version target

`pack.mcmeta` currently declares format **107.1**, which is Minecraft **26.2**.
It also still carries a `pack_format` field, which is optional for any pack
whose format is 82 or above and is only needed to stay loadable on older
clients. The repository's other packs are spread across several formats;
normalising them is tracked separately from this file. Check
[the pack format table](https://minecraft.wiki/w/Pack_format) for the number
matching the version you are actually targeting, and remember that **data pack
and resource pack formats are independent sequences** - do not copy one into
the other.

## What was removed from here

Two files were deleted here on 2026-10-08: an `inject-datalib` shell script and
a nested `.github/workflows/inject-datalib.yml` (that workflow no longer exists
- it never ran anyway, because only the repository-root `.github/` is read). The
script was self-declared broken: the `zipFull` Gradle task it invoked does not
exist in this build (the only zip task is `zipPacks`), so it could never
produce the `dataLib-full.zip` it wanted from a `dataLib` pack that also does
not exist anywhere in this repository. The workflow was nested inside `examples/`, so GitHub
never ran it - only the `.github/` at the repository root is read.

## Licence

[Unlicense](LICENSE) (public domain), matching the rest of the repository.
