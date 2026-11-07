# ======================================================================================
# macroengine:input/anvil
# ======================================================================================
#
# TRIGGERED BY: #macroengine:loop (polled every tick)
#
# PURPOSE:
#   Anvil-rename input. The player renames a marked carrier item
#   (custom_data={macroengine:{input:1b,inputItem:"anvil"}}, from give_anvil /
#   give_anvil_custom) in an anvil and takes the result out. The renamed item is
#   captured into macroengine:input anvil.old_name / anvil.new_name / anvil.raw
#   and the carrier is consumed (see private/anvil_capture).
#
# HOW IT KNOWS IT IS AN ANVIL (and not the player inventory):
#   Vanilla has no "which screen is open" query, so the pack builds the
#   evidence itself. A player is only examined during an ANVIL SESSION:
#
#   1. start  - the advancement macroengine:input/anvil_open fires when the
#               player opens an anvil (any #minecraft:anvil block) and tags them
#               macroengine.anvil_session (private/anvil_open).
#   2. proof  - the carrier must disappear from hotbar/inventory/offhand while
#               it is NOT on the cursor either. The only place it can be then is
#               the anvil's input slot. That sets macroengine.anvil_hidden.
#   3. capture- only a hidden carrier that now sits on the cursor WITH a
#               custom_name (the rename) is captured. A carrier picked up from
#               the inventory never passes through step 2, so it is ignored.
#   4. end    - capture, the carrier coming back into the inventory (anvil
#               closed or shift-clicked out) or a 60 second timeout.
#
# COST: nothing scans all players. With no session open the whole function is
# one cheap tag selector; a session player costs three item checks per tick.
#
# KNOWN LIMIT: a hidden carrier could in theory also be sitting in some other
# container GUI opened during the same 60 s. Items cannot be told apart by
# screen, only by this chain of evidence.
# ======================================================================================

execute unless entity @a[tag=macroengine.anvil_session] run return 0
execute as @a[tag=macroengine.anvil_session] at @s run function macroengine:input/private/anvil_tick
