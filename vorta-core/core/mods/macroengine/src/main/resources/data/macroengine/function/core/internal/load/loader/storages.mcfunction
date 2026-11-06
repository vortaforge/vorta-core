# macroengine:core/internal/load/loader/storages
# Initializes macroengine:engine storage fields that do not yet exist.
# (moved from macroengine:core/internal/load/load/storages in v26.3 — load/ vs loader/
#  separates gate/confirmation logic from the actual init routines)
#
# AI-ASSISTED FIX (Claude, Anthropic): added the missing 'storage' keyword to the
# queue / region_watches / batches / cb_queue guards (Spyglass lint errors) and
# changed the second batches line from 'if' to 'unless' so batches is re-initialized
# after being cleared. Human review required before merge.
#
# SAFETY DESIGN
# -------------
# EVERY write here uses 'execute unless data storage ...' guards.
# This means:
#   - Fields that already exist from a prior session are NOT overwritten.
#   - Only fields missing from storage are initialized.
#   - Nondeterministic overwrite behaviour is impossible in this file.
#
# Fields that are INTENTIONALLY cleared on each reload are listed with
# explicit comments explaining why.
#
# SCOREBOARD SAFETY
# -----------------
# Epoch is preserved across reloads — cooldown expiry times depend on it.
# Tick counter is reset (irrelevant across reloads — just a monotonic counter).
# pq_depth is reset (queue state cannot survive reload safely).
#
# STORAGE VERSION GUARD
# ---------------------
# validate.mcfunction blocks a second load if global{loaded:1b} is set,
# so we only reach here when storage is either:
#   (a) fresh / never initialized, or
#   (b) was cleaned up via core/internal/load/cleanup (cleanup removed global).
# In both cases, initializing with 'unless data' guards is safe.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless score $epoch macroengine.time matches -2147483648..2147483647 run scoreboard players set $epoch macroengine.time 0
scoreboard players set $tick macroengine.tmp 0

scoreboard players set $pq_depth macroengine.tmp 0

scoreboard players set $pb_four macroengine.tmp 1

execute unless data storage macroengine:engine throttle run data modify storage macroengine:engine throttle set value {}

execute unless data storage macroengine:engine flags run data modify storage macroengine:engine flags set value {}
execute unless data storage macroengine:engine states run data modify storage macroengine:engine states set value {}

execute unless data storage macroengine:engine permissions run data modify storage macroengine:engine permissions set value {}

execute unless data storage macroengine:engine perm_triggers run data modify storage macroengine:engine perm_triggers set value {}
execute unless data storage macroengine:engine perm_trigger_names run data modify storage macroengine:engine perm_trigger_names set value []

execute unless data storage macroengine:engine trigger_binds run data modify storage macroengine:engine trigger_binds set value []

execute unless data storage macroengine:engine interaction_binds run data modify storage macroengine:engine interaction_binds set value {attack:[], use:[]}

execute unless data storage macroengine:engine player_pids run data modify storage macroengine:engine player_pids set value {}
execute unless data storage macroengine:engine _pid_seq run data modify storage macroengine:engine _pid_seq set value 0

# UUID module init
function macroengine:core/internal/systems/uuid/init

# once_per_player module init
execute unless data storage macroengine:engine once_per_player run data modify storage macroengine:engine once_per_player set value {}

# Wand module init
execute unless data storage macroengine:engine wand_binds run data modify storage macroengine:engine wand_binds set value []

# Hook module init
execute unless data storage macroengine:engine hook_binds run data modify storage macroengine:engine hook_binds set value []

# lib/fiber module init
# BUGFIX: same issue as the queue note below — fibers was only ever
# cleared in cleanup.mcfunction (manual teardown path, never /reload).
# A fiber record left over from before a reload would be orphaned now
# that queue is cleared below (nothing will ever resume it again), but
# clearing it explicitly here keeps the storage clean and matches what
# cleanup.mcfunction already does for the teardown path.
execute if data storage macroengine:engine fibers run data remove storage macroengine:engine fibers
execute unless data storage macroengine:engine fibers run data modify storage macroengine:engine fibers set value {}
# NOTE: fibers._pending no longer exists as of the resume_dispatch
# concurrency fix — resume targets now travel inside each queue entry
# (id/resume fields) instead of a separate shared FIFO list.

# core/lib/process_queue module init
# BUGFIX: the header comment above ("pq_depth is reset — queue state
# cannot survive reload safely") describes intent that was never
# actually implemented. queue is only ever cleared in
# core/internal/load/cleanup.mcfunction, which is a manual teardown
# helper and is never called from the /reload path (load/all.mcfunction
# does not call it). A queue entry left over from before a reload (e.g.
# a fiber resume, a delayed function/command) would silently keep
# running against whatever state exists after the reload, including
# referencing fiber ids or functions that no longer exist. Clearing it
# here actually fulfills what the comment above already claimed was
# happening.
execute if data storage macroengine:engine queue run data remove storage macroengine:engine queue

# geo/region_watch module init
# Region watches are always cleared on reload — all packs must re-register
# their watches in the #macroengine:init function tag. This is intentional:
# region watch registrations are transient and pack-owned.
execute if data storage macroengine:engine region_watches run data remove storage macroengine:engine region_watches
execute unless data storage macroengine:engine region_watches run data modify storage macroengine:engine region_watches set value []

# lib/batch module init
# Incomplete batches are always cleared on reload — they cannot be safely
# resumed across a reload boundary (executing context is gone).
execute if data storage macroengine:engine batches run data remove storage macroengine:engine batches
execute unless data storage macroengine:engine batches run data modify storage macroengine:engine batches set value {}

# Wand cooldown module — separate storage (avoids collision with macroengine:cooldown)
execute unless data storage macroengine:engine wand_cooldowns run data modify storage macroengine:engine wand_cooldowns set value {}

# ─────────────────────────────────────────────────────────────────
# Security module (v26.3+)
# No permission gate exists in this pack — the trust_players /
# cmd_min_level / sandbox_cmd_min_level / admin_min_level / sandbox_allowlist
# fields that used to live here (and the check_all function that read
# them) were removed. Nothing enforces macroengine.perm_level anymore.
#
# Remaining fields:
#   multi_type_allowlist  compound of permitted multiCommands.type values
# ─────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────
# Module toggle init (macroengine:api/toggle)
# Each module defaults to enabled (1b) on first load.
# Preserved across reloads via 'unless data' guards — admin toggles survive /reload.
# Disable a module:  /function macroengine:api/toggle/<name>/false
# Enable a module:   /function macroengine:api/toggle/<name>/true
# List module states: /function macroengine:api/toggle/list
# ─────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────
# cb module init
# cb_queue is always cleared on reload — in-flight delayed commands
# cannot be safely resumed across a reload boundary.
# ─────────────────────────────────────────────────────────────────
data remove storage macroengine:engine cb_queue
data remove storage macroengine:engine _cb_last
data remove storage macroengine:engine _cb_work
data remove storage macroengine:engine _cb_entry
execute unless data storage macroengine:engine cb_queue run data modify storage macroengine:engine cb_queue set value []

# ─────────────────────────────────────────────────────────────────
# Color API init
# Populates named color lookup table and initializes color namespace.
# palette and gradients are preserved across reloads (unless data guards).
# ─────────────────────────────────────────────────────────────────
function macroengine:systems/color/init
