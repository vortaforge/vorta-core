# Static-analysis findings, 2026-10-30

These are **unresolved findings**, not claims of runtime testing or human
review. The cleanup's full Spyglass/strict-JSON run analyzed 12 pack roots,
coverage-checked 3,278 files, excluded three Ward test files, and reported
zero errors and **58 warnings**. The language server selected one version per
pack, not every version supported by the metadata. No Minecraft server was
started. A clean syntax result is not permission to publish: publication
remains paused pending appropriate human review and runtime validation.

| Area | Evidence and next step |
|---|---|
| QuickShare (one warning) | `drop_mainhand_copy.mcfunction` summoned an item entity with `Item.id` set to `minecraft:air`. Spyglass flags it, and [Minecraft Wiki](https://minecraft.wiki/w/Air) says this summon does nothing in Java Edition. **Changed on 2026-10-31 (statically, not runtime-tested):** the scratch entity now starts as a `minecraft:stone` placeholder that is overwritten from `SelectedItem`; it is killed if the copy fails. Separately, `share.mcfunction`'s last guard (`unless score ... matches 101..`) was true for every cooldown value 1-100, so the item was still dropped while "Cooldown active" was shown. The drop and the cooldown reset now both test `unless score ... matches 1..` before the reset runs, and an empty hand neither drops nor starts a cooldown. Both changes still need an isolated runtime test and human review before they count as fixed. |
| TunnelScript (27 warnings) | The metadata declares pack format 10, while the warning sites use the NBT text-component `plain` field. [Mojang introduced `plain` in 26.1](https://www.minecraft.net/en-us/article/minecraft-java-edition-26-1). Its handling on the declared older version was not tested; review compatibility rather than silently raising the pack version. |
| LeftClickDetection (16 warnings) | Spyglass selected 26.1.2 from the declared broad range and flagged `Team`, `NoAI`, `DeathTime` and `Size` on interaction entities. The source primarily uses plural `functions`/`tags/functions`, while [Mojang renamed these directories in 1.21](https://www.minecraft.net/en-us/article/minecraft-java-edition-1-21). The metadata range extends across that boundary; its actual compatibility needs review. This pack's README labels it archived. |
| RTWrapper datapacks (10 warnings) | Five privileged commands per pack exceed Spyglass's default permission level. Only exact path/message/file-hash exceptions are downgraded to warnings. Runtime authorization and operator safety remain unverified. |
| macroEngine (four warnings) | Spyglass reports a potentially undeclared `macroengine.rnd_idx` objective, an `Invisible` key on a chest minecart, and two `_comment` keys in item-modifier JSON. Correction (2026-10-31): the earlier note that the objective was not found being created was wrong - `scoreboard objectives add macroengine.rnd_idx dummy` is in `core/internal/load/loader/scoreboards.mcfunction`, which `core/internal/load/all.mcfunction` calls, so this warning looks like a false positive from file-by-file analysis (not runtime-checked). The `Invisible` and `_comment` warnings are unchanged: investigate ignored fields and runtime effects before relying on them. |

Warnings may include false positives, but they must not be silently dismissed.
These observations did not justify untested gameplay changes in the cleanup.
Future investigations should use the project's isolated server-backed CI
procedure only after the required human authorization; the Ward workflow is
currently disabled and was not run for this work.
