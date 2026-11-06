# ======================================================================================
# macroengine:systems/cmd_gate/check
# ======================================================================================
# The single gate every *stored-string* command executor in this pack must pass
# before it macro-executes its string (core/lib/once_cmd, the hook/wand/trigger
# callers, the work queue, multi_cmd, region_watch and the command-block runners).
#
# FAIL-CLOSED. The command runs only when ALL of these hold:
#   1. the cmd module is on (config module_cmd),
#   2. dynamic commands are enabled at all (config dynamic_cmd, default 0b),
#   3. @s passes api/perm/require for "cmd.dynamic" (a no-entity server/console
#      executor is trusted, the same convention as api/perm/require itself),
#   4. the string is present, 1..config.dynamic_cmd_max_len characters, and has no
#      newline / carriage return / tab in it,
#   5. its first token (the command root), lower-cased, is not on the blocklist
#      seeded by systems/cmd_gate/blocklist.
#
# NOT A MACRO FUNCTION. The command string is handled only as data in storage;
# it is never substituted into a line of this file. Callers copy their macro
# argument into in.cmd with a quoted set-value line, which means a command
# containing a double quote or backslash cannot even be captured that way and
# fails closed before this check runs (the command-block runners copy from
# storage instead and keep quotes working; only the root token is normalised).
#
# The blocklist is defence in depth, not the security boundary: it only sees
# the first token, so `execute ... run op @s` is an "execute" root and is not
# stopped by it. The boundary is (2) + (3): only enable dynamic_cmd and grant
# cmd.dynamic to players you already trust with function-permission-level
# commands. Like every datapack check this is a safeguard, not a sandbox -
# non-bypassable enforcement belongs in a Fabric mod (see gate/version).
#
# INPUT  (storage macroengine:cmd_gate):  in.cmd     the command string (no leading /)
# OUTPUT (storage macroengine:cmd_gate):  out.allowed 1b / 0b, out.error  reason
# RETURN: 1 when allowed, 0 when denied.
# NOTE: clobbers macroengine:input string/separator/n and macroengine:output
#       string.result (shared string-library scratch), like other systems do.
# ======================================================================================

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:cmd_gate out set value {allowed:0b,error:""}
data remove storage macroengine:cmd_gate tmp
data modify storage macroengine:cmd_gate tmp set value {}

execute if data storage macroengine:engine modules{cmd:0b} run data modify storage macroengine:cmd_gate out.error set value "module_cmd is off"
execute if data storage macroengine:engine modules{cmd:0b} run return 0
execute unless data storage macroengine:engine config{dynamic_cmd:1b} run data modify storage macroengine:cmd_gate out.error set value "dynamic commands are disabled (config dynamic_cmd)"
execute unless data storage macroengine:engine config{dynamic_cmd:1b} run return 0

data modify storage macroengine:perm_require in set value {perm:"cmd.dynamic",strict:1b}
execute store result score #macroengine.cg_perm macroengine.tmp run function macroengine:api/perm/require
execute unless score #macroengine.cg_perm macroengine.tmp matches 1 run data modify storage macroengine:cmd_gate out.error set value "missing permission cmd.dynamic"
execute unless score #macroengine.cg_perm macroengine.tmp matches 1 run return 0

data modify storage macroengine:cmd_gate tmp.cmd set string storage macroengine:cmd_gate in.cmd
execute unless data storage macroengine:cmd_gate tmp.cmd run data modify storage macroengine:cmd_gate out.error set value "no command"
execute unless data storage macroengine:cmd_gate tmp.cmd run return 0
execute store result score #macroengine.cg_len macroengine.tmp run data get storage macroengine:cmd_gate tmp.cmd
execute store result score #macroengine.cg_max macroengine.tmp run data get storage macroengine:engine config.dynamic_cmd_max_len
execute if score #macroengine.cg_max macroengine.tmp matches ..0 run scoreboard players set #macroengine.cg_max macroengine.tmp 256
execute if score #macroengine.cg_len macroengine.tmp matches ..0 run data modify storage macroengine:cmd_gate out.error set value "empty command"
execute if score #macroengine.cg_len macroengine.tmp matches ..0 run return 0
execute if score #macroengine.cg_len macroengine.tmp > #macroengine.cg_max macroengine.tmp run data modify storage macroengine:cmd_gate out.error set value "command too long (config dynamic_cmd_max_len)"
execute if score #macroengine.cg_len macroengine.tmp > #macroengine.cg_max macroengine.tmp run return 0

data modify storage macroengine:text s set from storage macroengine:cmd_gate tmp.cmd
execute store result score #macroengine.cg_hit macroengine.tmp run function macroengine:core/internal/text/ctl
function macroengine:core/internal/text/reset
execute if score #macroengine.cg_hit macroengine.tmp matches 1 run data modify storage macroengine:cmd_gate out.error set value "control character in command"
execute if score #macroengine.cg_hit macroengine.tmp matches 1 run return 0

data remove storage macroengine:input string
data remove storage macroengine:input separator
data remove storage macroengine:input n
data remove storage macroengine:input keep_empty
data modify storage macroengine:input string set from storage macroengine:cmd_gate tmp.cmd
data modify storage macroengine:input separator set value " "
data modify storage macroengine:input n set value 1
function macroengine:core/lib/string/split
execute unless data storage macroengine:output string.result[0] run data modify storage macroengine:cmd_gate out.error set value "no command root"
execute unless data storage macroengine:output string.result[0] run return 0
data modify storage macroengine:cmd_gate tmp.root set from storage macroengine:output string.result[0]

data modify storage macroengine:text s set from storage macroengine:cmd_gate tmp.root
execute store result score #macroengine.cg_safe macroengine.tmp run function macroengine:core/internal/text/safe
execute if score #macroengine.cg_safe macroengine.tmp matches 0 run data modify storage macroengine:cmd_gate out.error set value "quote or backslash in command root"
execute if score #macroengine.cg_safe macroengine.tmp matches 0 run function macroengine:core/internal/text/reset
execute if score #macroengine.cg_safe macroengine.tmp matches 0 run return 0
function macroengine:core/internal/text/lower
execute if data storage macroengine:text err run data remove storage macroengine:cmd_gate tmp.root
execute unless data storage macroengine:text err run data modify storage macroengine:cmd_gate tmp.root set from storage macroengine:text out
function macroengine:core/internal/text/reset
execute unless data storage macroengine:cmd_gate tmp.root run data modify storage macroengine:cmd_gate out.error set value "could not normalise command root"
execute unless data storage macroengine:cmd_gate tmp.root run return 0

function macroengine:systems/cmd_gate/blocklist
data modify storage macroengine:cmd_gate tmp.pending set from storage macroengine:engine cmd_blocklist
data modify storage macroengine:cmd_gate tmp.blocked set value 0b
function macroengine:systems/cmd_gate/_block_loop
execute if data storage macroengine:cmd_gate tmp{blocked:1b} run data modify storage macroengine:cmd_gate out.error set value "command root is on the blocklist"
execute if data storage macroengine:cmd_gate tmp{blocked:1b} run data modify storage macroengine:audit in set value {action:"cmd_gate.blocked"}
execute if data storage macroengine:cmd_gate tmp{blocked:1b} run data modify storage macroengine:audit in.detail set from storage macroengine:cmd_gate tmp.root
execute if data storage macroengine:cmd_gate tmp{blocked:1b} run function macroengine:systems/audit/record
execute if data storage macroengine:cmd_gate tmp{blocked:1b} run return 0

data modify storage macroengine:cmd_gate out.allowed set value 1b
data modify storage macroengine:cmd_gate out.error set value ""
data remove storage macroengine:cmd_gate tmp
return 1
