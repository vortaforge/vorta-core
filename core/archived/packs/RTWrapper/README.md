# RTWrapper

> ⚠️ **Archived.** This pack is archived and no longer maintained. The `vortaforge/core` datapacks are being superseded by [Fabric](https://fabricmc.net/) mods. Existing worlds using this pack will continue to work, but no new features or fixes are planned.

> ⚠️ **Structural exception (audit 2026-10-07) — needs a maintainer decision.**
> This directory breaks three conventions that the rest of the repo follows, and
> fixing them means moving ~700 files, so it was deliberately **not** done
> automatically:
>
> 1. **There is no top-level `pack.mcmeta`.** The datapack root is nested at
>    `datapack/RTWrapper-Datapack/`, so `packs/RTWrapper` itself is not a
>    loadable pack. Every other entry in `packs/` is. The Gradle pack tasks
>    (`zipPacks`, `checkPacks`, `mergeDatapacks`) discover packs by locating
>    `pack.mcmeta`, so they see the nested directory, not this one.
> 2. **It contains historical Fabric source** (`rtwrapper-fabric/`) under
>    `packs/`. This old implementation is intentionally excluded from the
>    Gradle build; the separate `mods/rtwrapper-mod` source was removed in
>    the 2026-10-30 cleanup. No RTWrapper Fabric mod is currently built.
> 3. **It says "Archived" but is not registered.** `archived/archive.json` holds
>    one entry (`runtoolkit-suite`); this pack is not in it, and it still lives
>    under `packs/`. `checkArchive` fails for an entry that is registered as
>    archived while still under `packs/`, so the banner and the registry cannot
>    both be satisfied as things stand.
>
> Related: `packs/RTWrapper-v1.0.1` (format 121, not currently included in
> `merge-manifest.json`). The three naming schemes — no suffix, `-1.21.1` (Minecraft version) and
> `-v1.0.1` (semver) — are not consistent with each other.

RTWrapper is a datapack for Java Edition 26.3.

## Layout

```text
datapack/RTWrapper-Datapack/      Standalone datapack root
datapack/commands-26.3.json       Command wrapper manifest + command parameter names
docs/API.md                       API/storage protocol
```

## Datapack API quick start

Generated command wrappers use meaningful command-specific parameter names. There is no generated catch-all or generic numeric parameter API.

Provide the named parameters in the order listed for that command in `datapack/commands-26.3.json`. The dispatcher calls the exact `<command>_<N>` variant and does not append unused params.

```mcfunction
# /tp @s 0 80 0 via queued handler
data modify storage rtwrapper:api request set value {cmd:"tp",params:{target:"@s",x:"0",y:"80",z:"0"}}
function rtwrapper:api/run

# /give @s minecraft:stone 1 via direct API
data modify storage rtwrapper:api params set value {target:"@s",item:"minecraft:stone",count:"1"}
function rtwrapper:api/commands/give
```

> **Note:** The previous `scoreboard` example in this section used the objective `rtw.test`, which was tied to an external integration and was not sandboxed. That example has been removed and will not work if you try to reuse it as-is — build your own `scoreboard` payload from `datapack/commands-26.3.json` instead.

Named convenience wrapper example:

```mcfunction
# $give $(target) $(item)$(components) $(count)
data modify storage rtwrapper:api params set value {target:"@s",item:"minecraft:stone",components:"",count:"1"}
function rtwrapper:api/commands/give_item
```

Autotick usage:

```mcfunction
function rtwrapper:api/autotick/on

data modify storage rtwrapper:api request set value {cmd:"say",params:{message:"queued hello"}}
function rtwrapper:api/enqueue
```

Autotick processes one queued action per tick. Use `function rtwrapper:api/run` only for immediate full queue drain.

See [`docs/API.md`](docs/API.md) for the full protocol and debug/silent controls.

## Safety

RTWrapper intentionally exposes privileged macro-command execution for trusted datapacks/admins. Do not copy untrusted player-controlled text into `rtwrapper:api request` or `rtwrapper:api params`.

## Known issue

Test functions (`api/commands/test`, `core/wrappers/internal/test`, and the `test_0`–`test_4` variants) were intended to be removed from the shipped datapack — they were loading on a normal client, which is not intended behavior. **This cleanup has not actually happened yet**: the files are still present in `datapack/RTWrapper-Datapack/data/rtwrapper/function/`. Treat them as unfinished/unsupported until they're removed in a future commit; do not rely on them.

These `test` variants are not on the `#minecraft:tick` path by default — they only run if something explicitly queues `cmd:"test"` (e.g. `test_4` drives `/test run ...`). Note that `/test` here is **vanilla Minecraft's own `/test` command** (present on any vanilla server, not exclusive to the GameTest framework), and its `test_block[mode=log]` logging behavior is not something RTWrapper implements — RTWrapper only forwards the macro parameters to it. If autotick is enabled and a caller repeatedly enqueues `cmd:"test"` with `action`/`test_name` params (accidentally or via injected input), each drain can trigger vanilla `/test`'s own tick/log behavior — including `test_block[mode=log]` writes — which is a real TPS and disk-growth risk under sustained/malicious queuing. This is not a default-tick issue; it's an injection/misuse-triggered one, consistent with the macro-injection risk already noted under Safety.
