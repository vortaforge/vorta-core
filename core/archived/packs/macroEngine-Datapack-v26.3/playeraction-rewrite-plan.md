# `core/internal/player` — independent rewrite plan (PlayerAction removal)

**Status:** planning document, not implemented. No code in this commit changes
`core/internal/player/`. This supersedes any assumption that the dependency is
a small, single-file-sized module like the former `core/internal/string`
(StringLib) removal — it is not. See scope below.

**AI disclosure:** this plan was produced with AI assistance (source analysis
and phased design), based on a read-through of the current
`core/internal/player/` tree. It has not been implemented or tested.

---

## 1. Why this is a bigger job than the StringLib removal

`core/internal/player/` is **82 `.mcfunction` files** plus 12 predicates and
27 advancement JSONs, covering three distinct subsystems:

1. **Lifecycle** — `enumerate`, `resolve`, `init`, `init_online`,
   `init_from_name`, `assign_pid`: module bootstrap and per-player ID
   assignment.
2. **State/statistics detection** — `player/tick`, `is_moving`,
   `process_data`, `remove_tags`, `reset_scores`, `set_uuid`: converts
   vanilla statistics (`minecraft.custom:*`) and predicates
   (`entity_properties`, `vehicle`) into `player_action.*` tags and one-shot
   event hooks.
3. **Click detection** — `click_detection/*` (`start`, `start_2`, `process`,
   `end`, `tick`, `tick_entities`, `tick_entities_2`,
   `attack_click_entity`, `interact_click_entity`) plus 27
   `interact_<block>` / `internal/interact_<block>` pairs: detects clicks on
   blocks and entities using an invisible `minecraft:interaction` entity
   tracked to the player via score-based UUID matching.

Only subsystem 3 carries PlayerAction-specific technique. Subsystems 1 and 2
are general use of vanilla mechanisms (statistics objectives, predicate
types, advancement-reward relaying) and are **not meaningfully
PlayerAction-derived** — they can be renamed and kept largely as-is.

## 2. Phase 1 — Namespace migration (low risk)

Scope: lifecycle + state/statistics subsystems, plus the 27
`interact_<block>` relay pairs.

- Rename the `player_action.*` objective/tag namespace to something
  macroEngine-owned (e.g. `pstate.*`). The current naming exists only for
  surface-level compatibility with PlayerAction's public interface; nothing
  requires keeping it.
- Leave the tick-pipeline logic (`remove_tags` → `is_moving` →
  `process_data` → `click_detection/tick` → `reset_scores`) structurally
  unchanged — it is a generic reset/detect/dispatch/reset pattern, not
  PlayerAction's algorithm.
- Leave the advancement-reward relay pattern for the 27 block-interact pairs
  unchanged; only the namespace changes. The specific `default_block_use`
  advancement conditions are Mojang's, not PlayerAction's.
- `assign_pid`'s sequential-counter approach is a generic ID-assignment
  pattern and needs no rewrite, only the namespace change.

Deliverable: a rename-only diff across ~60 of the 82 files, no behavioral
change expected.

## 3. Phase 2 — Click detection (the actual PlayerAction-derived part)

This is where real design decisions are needed. Two candidate approaches —
**no decision made yet; both are recorded for a later choice**:

### Option A — Same technique, independently structured implementation

The invisible-`minecraft:interaction`-entity-plus-teleport-tracking
technique is a documented, publicly known pattern in the Minecraft datapack
ecosystem (also used by the Smithed library convention — the current code
already tags entities `smithed.strict`). It is not PlayerAction's
invention. Under this option, "independent" means: keep the general
technique, but redesign the file layout, control flow, and naming away from
PlayerAction's structure, the way the StringLib rewrite was approached.

Rough shape:
- One state machine per player (`start` → `process` → `end`) tracking a
  single interaction-entity per player via a stored UUID-to-entity link.
- Opt-in check via the existing `custom_data` NBT flag on the held item,
  kept as-is (this is macroEngine's own toggle mechanism, not
  PlayerAction's).
- Cleanup sweep (equivalent of `tick_entities`/`tick_entities_2`) re-derived
  independently rather than ported line-for-line.

Risk: low technical risk (proven technique), moderate copying risk if the
rewrite isn't done from the described behavior rather than from reading
PlayerAction's actual source line-by-line.

### Option B — Different technique: advancement-only detection

Avoid the interaction-entity/teleport-tracking approach entirely. Use
`minecraft:default_block_use` and the attack/interact advancements directly
as the sole detection source, without spawning a tracking entity.

Trade-offs:
- Removes the entity-leak surface (no entities to clean up via
  `tick_entities`).
- Likely loses some precision — e.g. distinguishing *which* entity among
  several nearby was clicked may be harder without the interaction entity
  as a positional proxy.
- Needs in-game testing to validate; this is a genuinely different runtime
  behavior, not just a refactor, so it carries real risk of regressions
  that Option A (same technique, same observable behavior) does not.

**Recommendation (not yet adopted):** Option A is lower-risk because it
doesn't change observable behavior, only code organization — consistent with
how the StringLib dependency was removed. Option B is worth keeping on record
as a longer-term simplification if entity-leak edge cases turn out to matter
in practice.

## 4. Phase 3 — Documentation and license cleanup

- Remove the PlayerAction section from `THIRD_PARTY_LICENSES.md` once no
  distributed copy contains PlayerAction-derived code.
- Add a note to the AI-disclosure / CREDITS file: the click-detection
  subsystem was redesigned independently of PlayerAction (ICY105), using the
  same publicly documented `interaction`-entity technique (see Smithed
  library conventions), not PlayerAction's source.
- Update this file's header to "implemented" once Phase 2 lands, with a link
  to the actual PR.

## 5. What this plan does NOT do

- It does not ship any rewritten `core/internal/player/` code. That is
  future work, to be done file-by-file with testing, not produced
  wholesale in a planning pass.
- It does not pick between Option A and Option B for Phase 2 — that decision
  is left open per current instructions.
