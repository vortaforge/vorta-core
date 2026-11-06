# AFK Manager

> [!TIP]
> **AFK handling is server-side.** The mod only provides the timer and the command surface; nothing has to be installed on a player's client.

Server-side Fabric mod (Minecraft **1.21.1**, Java 21, dedicated server). Vanilla clients can join; nothing
is needed on the client.

## Behaviour

- A player counts as **active** when they move or turn (sampled once per second), send a chat message, or
  right-click a block.
- After `afkAfterSeconds` without activity they are marked **AFK** and (optionally) announced in chat.
- Activity ends AFK and announces the return. `/afk` toggles it manually (any player, no permission needed).
- Optionally, players who stay AFK for `kickAfterSeconds` are kicked. **Off by default.** Operators are
  exempt unless you change that.
- Timers run on server ticks, so a lagging server does not mass-mark players AFK.

## Config

`config/afk-manager.json` (created on first start; values are clamped, a broken file falls back to defaults):

```json
{
  "afkAfterSeconds": 300,
  "kickAfterSeconds": 0,
  "announce": true,
  "exemptOperatorsFromKick": true,
  "kickMessage": "Kicked for being AFK."
}
```

`kickAfterSeconds` must be `0` (off) or at least `afkAfterSeconds`; a lower value is raised to it.

## Limits

- Being pushed (water, pistons, entities) counts as movement, so such a player is not marked AFK.
- Players who only hold a mouse button (e.g. an AFK fish/mob farm) without moving or turning are treated as
  idle. Only chat, movement/turning and block right-clicks count as activity.
- Not a protection against AFK-bypass tools; a determined player can always fake activity.

## Build / test

```bash
./gradlew :mods:afk-manager:build     # from the repo root
```

The unit tests cover the Minecraft-free classes (`IdleTracker`, `MotionSample`, `AfkSettings`). The Fabric
wiring in `AfkManagerMod` can only be verified in a running server.

See [CREDITS.md](../../CREDITS.md) for AI-assistance disclosure.
