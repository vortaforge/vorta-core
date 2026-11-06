# macroengine:systems/diagnostics/checks/modules
# Internal: called by systems/diagnostics/collect. Verifies the apply contract for every module:
# macroengine:engine modules.<name> must exist, be a byte 0b/1b, and equal config.module_<name>.
# Counts enabled and disabled modules into #macroengine.dg_on / #macroengine.dg_off.
#
# The names below are constants written here, never player input, so they are safe to substitute
# into the macro lines of checks/module_one. Keep this list in sync with core/config/apply.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0

data modify storage macroengine:diagnostics work.pending set value ["cb","cmd","color","gamerule","interaction","item","macro","perm","block","container","store","title","trigger","wand","audit","geo","hook","log","logic","math","rate_limit","rng","sound","string","text","uuid"]
function macroengine:systems/diagnostics/checks/modules_step
