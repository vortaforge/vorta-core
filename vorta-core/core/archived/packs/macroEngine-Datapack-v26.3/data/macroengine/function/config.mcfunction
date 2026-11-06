# macroengine:config
# Single source of runtime configuration (replaces _rt_origin + scattered defaults).
# Other packs may read macroengine:engine config / macroengine.meta scores; do not hardcode.

# ── Version (263 = 26.3) ──────────────────────────────────────────
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard objectives add macroengine.meta dummy
scoreboard players set #vortacraftmc.packs.macroengine.version macroengine.meta 263

# Archived flag: opt-in, default 0 (the pack is in active development). Set it to 1 by hand to mark a copy as archived:
# scoreboard players set #vortacraftmc.archivedpacks.macroengine macroengine.meta 1
# Worlds that loaded an earlier build keep the value that build stored (it defaulted to 1); reset it with the line above and 0.
execute unless score #vortacraftmc.archivedpacks.macroengine macroengine.meta matches -2147483648..2147483647 run scoreboard players set #vortacraftmc.archivedpacks.macroengine macroengine.meta 0

# ── Engine defaults (only fill missing keys — preserves live data) ─
execute unless data storage macroengine:engine global run data modify storage macroengine:engine global set value {}
data modify storage macroengine:engine global.version set value "v26.3"

execute unless data storage macroengine:engine config run data modify storage macroengine:engine config set value {}

# Runtime config. EVERY key below changes behaviour; nothing here is informational.
# Defaults are only filled when a key is missing, so live values survive /reload.
# Change values with core/config/set (validated and clamped, applied at once), read them with
# core/config/get, list them with core/config/list, reset with core/config/reset.
# core/config/apply copies them to the scores/storage the engine reads. Full table: docs/config.md.

# Schema: type and range of every key (used by core/config/set)
data modify storage macroengine:engine config_schema set value {}
data modify storage macroengine:engine config_schema merge value {module_cb:{t:"bool"},module_cmd:{t:"bool"},module_color:{t:"bool"},module_gamerule:{t:"bool"},module_interaction:{t:"bool"},module_item:{t:"bool"},module_macro:{t:"bool"},module_perm:{t:"bool"},module_block:{t:"bool"},module_container:{t:"bool"}}
data modify storage macroengine:engine config_schema merge value {module_store:{t:"bool"},module_title:{t:"bool"},module_trigger:{t:"bool"},module_wand:{t:"bool"},module_audit:{t:"bool"},module_geo:{t:"bool"},module_hook:{t:"bool"},module_log:{t:"bool"}}
data modify storage macroengine:engine config_schema merge value {module_logic:{t:"bool"},module_math:{t:"bool"},module_rate_limit:{t:"bool"},module_rng:{t:"bool"},module_sound:{t:"bool"},module_string:{t:"bool"},module_text:{t:"bool"},module_uuid:{t:"bool"}}
data modify storage macroengine:engine config_schema merge value {sys_time:{t:"bool"},sys_player:{t:"bool"},sys_queue:{t:"bool"},sys_hud:{t:"bool"},sys_admin:{t:"bool"},tick_rate:{t:"int",min:1,max:1200},hud_rate:{t:"int",min:1,max:1200},admin_rate:{t:"int",min:1,max:1200}}
data modify storage macroengine:engine config_schema merge value {hook_interval:{t:"int",min:1,max:1200},geo_interval:{t:"int",min:1,max:1200},interaction_interval:{t:"int",min:1,max:1200},wand_interval:{t:"int",min:1,max:1200},perm_trigger_interval:{t:"int",min:1,max:1200},queue_max_depth:{t:"int",min:1,max:4096},log_level:{t:"int",min:0,max:4},reload_warn:{t:"bool"}}
data modify storage macroengine:engine config_schema merge value {validate_max_name:{t:"int",min:8,max:256},store_default_lang:{t:"str",max:16},store_max_template:{t:"int",min:16,max:32767},store_max_tokens:{t:"int",min:1,max:1024},store_tok_score:{t:"bool"},store_tok_player:{t:"bool"},store_tok_entity:{t:"bool"},store_tok_global:{t:"bool"}}
data modify storage macroengine:engine config_schema merge value {store_tok_pvar:{t:"bool"},store_tok_args:{t:"bool"},store_keep_unknown:{t:"bool"},title_fade_in:{t:"int",min:0,max:1200},title_stay:{t:"int",min:0,max:72000},title_fade_out:{t:"int",min:0,max:1200}}
data modify storage macroengine:engine config_schema merge value {dynamic_cmd:{t:"bool"},dynamic_cmd_max_len:{t:"int",min:1,max:4096},perm_enforce:{t:"bool"},perm_cmd:{t:"bool"}}

# Legacy values: worlds from before the config existed keep what an admin had set
scoreboard objectives add macroengine.tick_flags dummy
execute unless data storage macroengine:engine config.module_cb if data storage macroengine:engine modules.cb run data modify storage macroengine:engine config.module_cb set from storage macroengine:engine modules.cb
execute unless data storage macroengine:engine config.module_geo if data storage macroengine:engine modules.geo run data modify storage macroengine:engine config.module_geo set from storage macroengine:engine modules.geo
execute unless data storage macroengine:engine config.module_hook if data storage macroengine:engine modules.hook run data modify storage macroengine:engine config.module_hook set from storage macroengine:engine modules.hook
execute unless data storage macroengine:engine config.module_interaction if data storage macroengine:engine modules.interaction run data modify storage macroengine:engine config.module_interaction set from storage macroengine:engine modules.interaction
execute unless data storage macroengine:engine config.module_perm if data storage macroengine:engine modules.perm run data modify storage macroengine:engine config.module_perm set from storage macroengine:engine modules.perm
execute unless data storage macroengine:engine config.module_wand if data storage macroengine:engine modules.wand run data modify storage macroengine:engine config.module_wand set from storage macroengine:engine modules.wand
execute unless data storage macroengine:engine config.sys_time if score #sys_time macroengine.tick_flags matches 0 run data modify storage macroengine:engine config.sys_time set value 0b
execute unless data storage macroengine:engine config.sys_player if score #sys_player macroengine.tick_flags matches 0 run data modify storage macroengine:engine config.sys_player set value 0b
execute unless data storage macroengine:engine config.sys_queue if score #sys_queue macroengine.tick_flags matches 0 run data modify storage macroengine:engine config.sys_queue set value 0b
execute unless data storage macroengine:engine config.sys_hud if score #sys_hud macroengine.tick_flags matches 0 run data modify storage macroengine:engine config.sys_hud set value 0b
execute unless data storage macroengine:engine config.sys_admin if score #sys_admin macroengine.tick_flags matches 0 run data modify storage macroengine:engine config.sys_admin set value 0b

# Defaults
execute unless data storage macroengine:engine config.module_cb run data modify storage macroengine:engine config.module_cb set value 1b
execute unless data storage macroengine:engine config.module_cmd run data modify storage macroengine:engine config.module_cmd set value 1b
execute unless data storage macroengine:engine config.module_color run data modify storage macroengine:engine config.module_color set value 1b
execute unless data storage macroengine:engine config.module_gamerule run data modify storage macroengine:engine config.module_gamerule set value 1b
execute unless data storage macroengine:engine config.module_interaction run data modify storage macroengine:engine config.module_interaction set value 1b
execute unless data storage macroengine:engine config.module_item run data modify storage macroengine:engine config.module_item set value 1b
execute unless data storage macroengine:engine config.module_macro run data modify storage macroengine:engine config.module_macro set value 1b
execute unless data storage macroengine:engine config.module_perm run data modify storage macroengine:engine config.module_perm set value 1b
execute unless data storage macroengine:engine config.module_block run data modify storage macroengine:engine config.module_block set value 1b
execute unless data storage macroengine:engine config.module_container run data modify storage macroengine:engine config.module_container set value 1b
execute unless data storage macroengine:engine config.module_store run data modify storage macroengine:engine config.module_store set value 1b
execute unless data storage macroengine:engine config.module_title run data modify storage macroengine:engine config.module_title set value 1b
execute unless data storage macroengine:engine config.module_trigger run data modify storage macroengine:engine config.module_trigger set value 1b
execute unless data storage macroengine:engine config.module_wand run data modify storage macroengine:engine config.module_wand set value 1b
execute unless data storage macroengine:engine config.module_audit run data modify storage macroengine:engine config.module_audit set value 1b
execute unless data storage macroengine:engine config.module_geo run data modify storage macroengine:engine config.module_geo set value 1b
execute unless data storage macroengine:engine config.module_hook run data modify storage macroengine:engine config.module_hook set value 1b
execute unless data storage macroengine:engine config.module_log run data modify storage macroengine:engine config.module_log set value 1b
execute unless data storage macroengine:engine config.module_logic run data modify storage macroengine:engine config.module_logic set value 1b
execute unless data storage macroengine:engine config.module_math run data modify storage macroengine:engine config.module_math set value 1b
execute unless data storage macroengine:engine config.module_rate_limit run data modify storage macroengine:engine config.module_rate_limit set value 1b
execute unless data storage macroengine:engine config.module_rng run data modify storage macroengine:engine config.module_rng set value 1b
execute unless data storage macroengine:engine config.module_sound run data modify storage macroengine:engine config.module_sound set value 1b
execute unless data storage macroengine:engine config.module_string run data modify storage macroengine:engine config.module_string set value 1b
execute unless data storage macroengine:engine config.module_text run data modify storage macroengine:engine config.module_text set value 1b
execute unless data storage macroengine:engine config.module_uuid run data modify storage macroengine:engine config.module_uuid set value 1b
execute unless data storage macroengine:engine config.sys_time run data modify storage macroengine:engine config.sys_time set value 1b
execute unless data storage macroengine:engine config.sys_player run data modify storage macroengine:engine config.sys_player set value 1b
execute unless data storage macroengine:engine config.sys_queue run data modify storage macroengine:engine config.sys_queue set value 1b
execute unless data storage macroengine:engine config.sys_hud run data modify storage macroengine:engine config.sys_hud set value 1b
execute unless data storage macroengine:engine config.sys_admin run data modify storage macroengine:engine config.sys_admin set value 1b
execute unless data storage macroengine:engine config.tick_rate run data modify storage macroengine:engine config.tick_rate set value 1
execute unless data storage macroengine:engine config.hud_rate run data modify storage macroengine:engine config.hud_rate set value 2
execute unless data storage macroengine:engine config.admin_rate run data modify storage macroengine:engine config.admin_rate set value 4
execute unless data storage macroengine:engine config.hook_interval run data modify storage macroengine:engine config.hook_interval set value 1
execute unless data storage macroengine:engine config.geo_interval run data modify storage macroengine:engine config.geo_interval set value 1
execute unless data storage macroengine:engine config.interaction_interval run data modify storage macroengine:engine config.interaction_interval set value 1
execute unless data storage macroengine:engine config.wand_interval run data modify storage macroengine:engine config.wand_interval set value 1
execute unless data storage macroengine:engine config.perm_trigger_interval run data modify storage macroengine:engine config.perm_trigger_interval set value 1
execute unless data storage macroengine:engine config.queue_max_depth run data modify storage macroengine:engine config.queue_max_depth set value 256
execute unless data storage macroengine:engine config.log_level run data modify storage macroengine:engine config.log_level set value 3
execute unless data storage macroengine:engine config.reload_warn run data modify storage macroengine:engine config.reload_warn set value 1b
execute unless data storage macroengine:engine config.validate_max_name run data modify storage macroengine:engine config.validate_max_name set value 64
execute unless data storage macroengine:engine config.store_default_lang run data modify storage macroengine:engine config.store_default_lang set value "en_us"
execute unless data storage macroengine:engine config.store_max_template run data modify storage macroengine:engine config.store_max_template set value 8192
execute unless data storage macroengine:engine config.store_max_tokens run data modify storage macroengine:engine config.store_max_tokens set value 128
execute unless data storage macroengine:engine config.store_tok_score run data modify storage macroengine:engine config.store_tok_score set value 1b
execute unless data storage macroengine:engine config.store_tok_player run data modify storage macroengine:engine config.store_tok_player set value 1b
execute unless data storage macroengine:engine config.store_tok_entity run data modify storage macroengine:engine config.store_tok_entity set value 1b
execute unless data storage macroengine:engine config.store_tok_global run data modify storage macroengine:engine config.store_tok_global set value 1b
execute unless data storage macroengine:engine config.store_tok_pvar run data modify storage macroengine:engine config.store_tok_pvar set value 1b
execute unless data storage macroengine:engine config.store_tok_args run data modify storage macroengine:engine config.store_tok_args set value 1b
execute unless data storage macroengine:engine config.store_keep_unknown run data modify storage macroengine:engine config.store_keep_unknown set value 1b
execute unless data storage macroengine:engine config.title_fade_in run data modify storage macroengine:engine config.title_fade_in set value 10
execute unless data storage macroengine:engine config.title_stay run data modify storage macroengine:engine config.title_stay set value 70
execute unless data storage macroengine:engine config.title_fade_out run data modify storage macroengine:engine config.title_fade_out set value 20
# Stored-string command execution is OFF by default; see docs/cmd_gate.md.
execute unless data storage macroengine:engine config.dynamic_cmd run data modify storage macroengine:engine config.dynamic_cmd set value 0b
execute unless data storage macroengine:engine config.dynamic_cmd_max_len run data modify storage macroengine:engine config.dynamic_cmd_max_len set value 256

# Permission system switches (docs/perm.md).
#   perm_default  (macroengine:engine perm_default, NOT inside config, so core/config/reset keeps it) is the value
#                 perm_enforce takes when it is created or reset. Ships as 1b: nothing gets looser on update.
#   perm_enforce  1b = api/perm/require and api/perm/check enforce permissions, 0b = every such check passes.
#   perm_cmd      1b = every api/cmd/<name> wrapper also needs the permission cmd.<name> (only with perm_enforce 1b).
execute unless data storage macroengine:engine perm_default run data modify storage macroengine:engine perm_default set value 1b
execute unless data storage macroengine:engine config.perm_enforce run data modify storage macroengine:engine config.perm_enforce set from storage macroengine:engine perm_default
execute unless data storage macroengine:engine config.perm_cmd run data modify storage macroengine:engine config.perm_cmd set value 0b

# Revision marker: core/config/ensure compares it, so adding a key means bumping this number.
data modify storage macroengine:engine config_rev set value 4

# Permission gates live in api/perm/* and systems/cmd_gate (see core/internal/load/loader/storages
# for the remaining, non-gate security. fields: sandbox_allowlist,
# multi_type_allowlist).
execute unless data storage macroengine:engine security run data modify storage macroengine:engine security set value {}

# Generic flag storage used by systems/flag/*.
execute unless data storage macroengine:engine flags run data modify storage macroengine:engine flags set value {}
