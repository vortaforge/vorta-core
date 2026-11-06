# DL Tick Engine — Simplified Entry Point
# Driven by #minecraft:tick function tag (guaranteed 1/game-tick, no drift).
#
# Runtime channel registry removed. Systems are called directly from
# core/tick/dispatch.mcfunction with fixed rates (see that file).
# Do NOT add per-system logic here — add it to dispatch.mcfunction instead.
#
# Merged in from the former macroengine.main:macroengine/tick; this function is called
# directly via #minecraft:tick, see data/minecraft/tags/function/tick.json.

# Runtime config: fill and apply anything missing (worlds loaded by an older version)
execute unless score #macroengine.gate.2 vortaforge.gate matches 0 unless score #macroengine.permit vortaforge.gate matches 1 run function macroengine:gate/permit_tick
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute unless score #macroengine.gate.3 vortaforge.gate matches 0 as @a[tag=!macroengine.consented] run function macroengine:gate/consent_tick
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
function macroengine:core/config/ensure

# Config-level pause guard (separate from the storage-level pause below)
execute if score #vortacraftmc.packs.macroengine.config.tick.pause macroengine.meta matches 1 run return 0

# Config not applied yet (before the first load finished): nothing to do
execute unless score #vortacraftmc.packs.macroengine.config.tick.rate macroengine.meta matches 1.. run return 0

# tick_rate: run the engine once every N game ticks (core/config/apply keeps the rate >= 1)
scoreboard players add #gt_ctr macroengine.tick 1
execute if score #gt_ctr macroengine.tick matches 2000000000.. run scoreboard players set #gt_ctr macroengine.tick 0
scoreboard players operation #gt_mod macroengine.tick = #gt_ctr macroengine.tick
scoreboard players operation #gt_mod macroengine.tick %= #vortacraftmc.packs.macroengine.config.tick.rate macroengine.meta
execute unless score #gt_mod macroengine.tick matches 0 run return 0

# Guard: no players online → nothing to process
execute unless entity @a run return 0

# Guard: engine not initialised
# (loaded flag lives under global.loaded — see macroengine:core/internal/load/all which sets
#  `macroengine:engine global.loaded`)
execute unless data storage macroengine:engine global{loaded:1b} run return 0

# Guard: globally paused (set/clear via: data merge storage macroengine:engine {tick:{paused:1b}} )
execute if data storage macroengine:engine tick{paused:1b} run return 0

# Per-player input polling (writable book, command block minecart, etc.) —
# independent of the dispatch chain below.
execute as @a run function #macroengine:loop

function macroengine:core/tick/dispatch
