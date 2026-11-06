# LevelOp

> [!NOTE]
> **This is example code, not production code.** Permission checks, persistence and error handling are deliberately minimal; harden it to your own requirements when you copy it.

Fabric mod for Minecraft 26.3 that extends the vanilla `/op` command with an
explicit permission-level argument.

## What it adds

- `/op <targets>` — unchanged vanilla behaviour (grants op at the level from
  `op-permission-level` in `server.properties`).
- `/op <targets> <level>` — **new**. Grants op at the given `level` (1-4),
  regardless of the server's default `op-permission-level`.

Both require permission level 3 to run, same as vanilla `/op`.

## ⚠️ Known risk: Loom is pinned to 1.15.5

This subproject is pinned to `fabric-loom` **1.15.5**. The pin is stale and
should move, but note first that three of the reasons previously given here for
it were wrong — they are corrected below rather than repeated, because each one
points a reader at the wrong conclusion:

- ~~"to match the other subprojects in this monorepo (`mods/datapack-blocker`)"~~
  **Not true.** `mods/datapack-blocker` targets Minecraft **1.21.1**, which is
  obfuscated and still resolves Yarn mappings. This subproject targets **26.3**,
  which ships unobfuscated with no Yarn layer at all. They share a version
  number by coincidence; there is no consistency being preserved by keeping
  them equal, and bumping this one breaks nothing over there.
- ~~"the root CI's Gradle 9.4.0"~~ **Not true.** The wrapper is Gradle
  **9.8.0** (`gradle/wrapper/gradle-wrapper.properties`). Loom 1.16 requires
  Gradle 9.4 as a *minimum*, which may be where the number came from; it is not
  what this repository runs.
- ~~"Loom only gained the ability to handle unobfuscated jars … starting at
  1.15.5 … it's the floor"~~ **Not true.** Unobfuscated-jar support landed in
  **Loom 1.14**, which also introduced the dedicated `net.fabricmc.fabric-loom`
  plugin id for non-remapping builds. 1.15.5 is therefore comfortably above the
  floor, not sitting on it.

What *is* true:

- MC 26.x ships **unobfuscated** — there is no `net.fabricmc:yarn` for 26.3 to
  depend on, and 1.21.11 was the last obfuscated release.
- FabricMC recommends **Loom 1.17 with Gradle 9.6+** for Minecraft 26.3
  ([fabricmc.net/2026/09/15/263.html](https://fabricmc.net/2026/09/15/263.html));
  **1.18** is the current release. So the pin is roughly three minors behind
  the recommendation for its own target version, and the gap is the actual
  risk — not the floor argument above.
- `gradle.properties` sets `fabric.loom.disableObfuscation=true` to tell Loom
  to skip mapping resolution. Because of this, `build.gradle` uses plain
  `implementation` for `fabric-loader` and `fabric-api` instead of
  `modImplementation` — with obfuscation disabled, Loom's remap-configuration
  setup (`RemapConfigurations.setupForSourceSet`) returns early and never
  creates the `mod*` configurations, so `modImplementation` would silently
  not resolve as expected.

If the build still fails after the fixes below, the most likely next problem
is that a *newer* Loom point release fixed something in the unobfuscated-jar
path that 1.15.5 doesn't have. If so, this subproject will need its own Loom
version bump independent of the rest of the repo (Gradle plugin versions are
per-subproject in a Groovy multi-project build) — check
https://github.com/FabricMC/fabric-loom/releases between 1.15.5 and whatever
is current for anything mentioning 26.x/unobfuscated fixes.

## ⚠️ Known risk: mappings written against 1.21.9-1.21.11, not a real 26.3 build

MC 26.x ships **unobfuscated** — Mojang's own class/method names *are* the
compiled names, there is no separate Yarn mapping layer. That means the code
in `LevelOpMod.java` has to be written directly against Mojang's real names
(`CommandSourceStack`, `PlayerList`, `NameAndId`, ...) rather than the
familiar Yarn ones (`ServerCommandSource`, `PlayerManager`, `GameProfile`, ...).

I could not get access to an actual 26.3 jar or javadoc to confirm the exact
signatures against that specific build. What's in this file is confirmed
against Mojang mappings history through **1.21.11** (the last release before
the 26.x renumbering) — 26.3 is very likely identical or extremely close,
but two specific spots are flagged with inline `NOTE` comments in
`LevelOpMod.java` because Mojang introduced a new permission-level system
(`PermissionLevel` enum, `LevelBasedPermissionSet`) starting at 1.21.11, and
it's not confirmed whether it fully replaced the old `int`-based APIs by
26.3 or is running alongside them:

1. `CommandSourceStack#hasPermission(int)` — used for the `.requires(...)`
   permission check. Confirmed present through 1.21.11. If 26.3 requires a
   `PermissionLevel` enum value instead of a raw `int` here, this is the
   line to fix.
2. `PlayerList#op(NameAndId, Optional<Integer>, Optional<Boolean>)` — the
   overload this mod relies on to grant a *specific* level directly (instead
   of vanilla's `op(NameAndId)`, which always uses the server's
   `op-permission-level` default). Confirmed present in 1.21.9 through
   1.21.11. If 26.3 changed the middle parameter from `Optional<Integer>` to
   `Optional<PermissionLevel>`, swap `Optional.of(level)` for
   `Optional.of(PermissionLevel.byId(level))` (or equivalent).

If either has changed, the compiler error will point straight at the
mismatched line — this isn't a design problem, just two call sites that may
need a small signature update once you're building against the real 26.3
jar.

## ⚠️ Known risk: Loom is pinned to 1.15.5

This subproject is deliberately pinned to `fabric-loom` **1.15.5** to match
the other subprojects in this monorepo (`mods/datapack-blocker`) and the root CI's Gradle 9.4.0. This was chosen
over bumping to a newer Loom for consistency — **but it means MC 26.3
support is not guaranteed** and needs verifying:

- Loom only gained the ability to handle unobfuscated jars
  (`MinecraftJarProcessor.isUnobfuscated()`) starting at **1.15.5**, which is
  why 1.15.5 happens to still work here at all — it's the floor, not a
  comfortable margin.
- `gradle.properties` sets `fabric.loom.disableObfuscation=true` to tell Loom
  to skip mapping resolution. Because of this, `build.gradle` uses plain
  `implementation` for `fabric-loader` and `fabric-api` instead of
  `modImplementation` — with obfuscation disabled, Loom's remap-configuration
  setup (`RemapConfigurations.setupForSourceSet`) returns early and never
  creates the `mod*` configurations, so `modImplementation` would silently
  not resolve as expected.

If the build still fails after the fixes above, the most likely next problem
is that a *newer* Loom point release fixed something in the unobfuscated-jar
path that 1.15.5 doesn't have. If so, this subproject will need its own Loom
version bump independent of the rest of the repo (Gradle plugin versions are
per-subproject in a Groovy multi-project build) — check
https://github.com/FabricMC/fabric-loom/releases between 1.15.5 and whatever
is current for anything mentioning 26.x/unobfuscated fixes.

## Before building

1. Confirm Fabric Loader / Fabric API versions are still current on
   https://fabricmc.net/develop and https://modrinth.com/mod/fabric-api —
   this project was written against Loader 0.19.5 and Fabric API
   0.161.0+26.3. Specifically check that whatever Fabric API build you pick
   for 26.3 doesn't itself require a newer Loom than 1.15.5.
2. You'll need JDK 25 installed (Minecraft 26.3 requires it).
3. Skim the two risk sections above before your first build — they tell you
   exactly what to check if `./gradlew build` fails.

## Build

```
./gradlew build
```

The mod jar will be in `build/libs/`.

## Notes on implementation

- No mixins are used. The mod registers an *additional* branch under the
  existing `op` command literal via `CommandRegistrationCallback`, so vanilla
  `/op <targets>` keeps working exactly as before.
- Unlike the mod's first draft (which used Yarn-style `PlayerManager` +
  reflection to overwrite an ops-list entry), this version uses
  `PlayerList#op(NameAndId, Optional<Integer>, Optional<Boolean>)`, which
  grants the requested level *directly* — no reflection, no re-writing
  `ops.json` after the fact.
