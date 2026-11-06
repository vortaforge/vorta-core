# Join Throttle

> [!NOTE]
> **This mod is not a security boundary.** It slows down brute-force and spam connection attempts; real DDoS protection needs a proxy layer in front of the server.

Server-side Fabric mod (Minecraft **1.21.1**, Java 21, dedicated server) that limits how often a single
address may log in within a time window.

Without it, a client that connects/disconnects in a loop makes the server repeatedly load a player into the
world, spams the chat with join/leave messages and burns CPU on chunk loading. Join Throttle rejects those
logins **during the login phase** (the same check vanilla uses for bans and the whitelist), so the rejected
client never enters the world.

## Behaviour

- Default: at most **5** logins per address per **30 s** (sliding window).
- A client that keeps hammering stays blocked until it has been quiet for a full window; a client that stops
  is let back in automatically.
- The first rejection per block episode is logged (with the address); repeats are silent, so an attack cannot
  also flood your log.
- IPv6 addresses are counted per **/64**, since one IPv6 customer controls a whole /64.
- Memory is bounded (4096 tracked addresses). Under an attack from more addresses than that, the least
  recently seen ones are forgotten first.

## Config

`config/join-throttle.json` (created on first start; values are clamped, a broken file falls back to defaults):

```json
{
  "maxJoins": 5,
  "windowSeconds": 30,
  "exemptAddresses": [],
  "denyMessage": "Too many connection attempts. Please wait a moment and try again."
}
```

`exemptAddresses` takes IP literals in any spelling (`"::1"` and `"0:0:0:0:0:0:0:1"` are the same address;
an IPv4-mapped form like `"::ffff:10.0.0.1"` matches `10.0.0.1`). Hostnames are not resolved and never match.

## Limits - read before relying on it

- **Behind a proxy (Velocity, BungeeCord, a TCP tunnel/reverse proxy) every player appears to come from the
  proxy's address.** Either put the proxy in `exemptAddresses` (then the mod does nothing for proxied
  traffic) or do not use this mod there; throttle at the proxy instead.
- It runs after the Mojang session check. It does **not** stop handshake-level or network-level floods - use a
  firewall / your host's DDoS protection for those.
- Connections without a usable IP address (e.g. an embedded/local connection) are never throttled.
- Shared networks (school, café, mobile carrier NAT) look like one address; raise `maxJoins` if that applies.

## Build / test

```bash
./gradlew :mods:join-throttle:build     # from the repo root
```

The unit tests cover the Minecraft-free classes (`AttemptLimiter`, `AddressKeys`, `ThrottleSettings`).
The mixin (`PlayerManagerMixin`, targets `PlayerManager#checkCanJoin`) can only be verified in a running
server: start one and reconnect more than `maxJoins` times quickly.

See [CREDITS.md](../../CREDITS.md) for AI-assistance disclosure.
