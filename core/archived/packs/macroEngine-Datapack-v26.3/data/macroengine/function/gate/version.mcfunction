# Gate 1 - version gate (vortaforge/core). Called first from macroengine:setup.
# Refuses to run when this world was last loaded by a NEWER version of this pack
# (downgrade protection). A first install or an upgrade passes and records the version.
# Toggle: function macroengine:gate/set/1_off | 1_on. Default: on.
# Gates 4 and 5 are evaluated in gate/load_guard, called from here.
# Safeguard, not a sandbox: a datapack is plain text and the checks can be deleted.
# Non-bypassable enforcement belongs in a Fabric mod.
scoreboard objectives add vortaforge.gate dummy
scoreboard objectives add macroengine.permit trigger
scoreboard objectives add macroengine.consent trigger
scoreboard objectives add macroengine.dlg_yes trigger
scoreboard objectives add macroengine.dlg_no trigger
execute unless score #macroengine.gate.1 vortaforge.gate = #macroengine.gate.1 vortaforge.gate run scoreboard players set #macroengine.gate.1 vortaforge.gate 1
execute unless score #macroengine.gate.2 vortaforge.gate = #macroengine.gate.2 vortaforge.gate run scoreboard players set #macroengine.gate.2 vortaforge.gate 1
execute unless score #macroengine.gate.3 vortaforge.gate = #macroengine.gate.3 vortaforge.gate run scoreboard players set #macroengine.gate.3 vortaforge.gate 1
execute unless score #macroengine.gate.4 vortaforge.gate = #macroengine.gate.4 vortaforge.gate run scoreboard players set #macroengine.gate.4 vortaforge.gate 1
execute unless score #macroengine.gate.5 vortaforge.gate = #macroengine.gate.5 vortaforge.gate run scoreboard players set #macroengine.gate.5 vortaforge.gate 1
execute unless score #macroengine.installed vortaforge.gate = #macroengine.installed vortaforge.gate run scoreboard players set #macroengine.installed vortaforge.gate 0
scoreboard players set #macroengine.expected vortaforge.gate 1
scoreboard players set #macroengine.version vortaforge.gate 0
execute if score #macroengine.installed vortaforge.gate <= #macroengine.expected vortaforge.gate run scoreboard players set #macroengine.version vortaforge.gate 1
execute if score #macroengine.version vortaforge.gate matches 1 run scoreboard players operation #macroengine.installed vortaforge.gate = #macroengine.expected vortaforge.gate
execute if score #macroengine.version vortaforge.gate matches 0 if score #macroengine.gate.1 vortaforge.gate matches 0 run scoreboard players set #macroengine.version vortaforge.gate 1
function macroengine:gate/load_guard
function macroengine:gate/refresh
execute if score #macroengine.version vortaforge.gate matches 0 run tellraw @a {"text":"[macroengine] This world was saved with a newer version of this datapack. macroengine stays inactive (version gate).","color":"red"}
execute if score #macroengine.version vortaforge.gate matches 1 unless score #macroengine.gate.2 vortaforge.gate matches 0 unless score #macroengine.permit vortaforge.gate matches 1 run function macroengine:gate/permit_prompt
