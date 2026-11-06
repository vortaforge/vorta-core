# Gate 1 - version gate (vortaforge/core). Called first from rtwrapper:core/load.
# Refuses to run when this world was last loaded by a NEWER version of this pack
# (downgrade protection). A first install or an upgrade passes and records the version.
# Toggle: function rtwrapper:gate/set/1_off | 1_on. Default: on.
# Safeguard, not a sandbox: a datapack is plain text and the checks can be deleted.
# Non-bypassable enforcement belongs in a Fabric mod.
scoreboard objectives add vortaforge.gate dummy
scoreboard objectives add rtwrapper.permit trigger
scoreboard objectives add rtwrapper.consent trigger
execute unless score #rtwrapper.gate.1 vortaforge.gate = #rtwrapper.gate.1 vortaforge.gate run scoreboard players set #rtwrapper.gate.1 vortaforge.gate 1
execute unless score #rtwrapper.gate.2 vortaforge.gate = #rtwrapper.gate.2 vortaforge.gate run scoreboard players set #rtwrapper.gate.2 vortaforge.gate 1
execute unless score #rtwrapper.gate.3 vortaforge.gate = #rtwrapper.gate.3 vortaforge.gate run scoreboard players set #rtwrapper.gate.3 vortaforge.gate 1
execute unless score #rtwrapper.installed vortaforge.gate = #rtwrapper.installed vortaforge.gate run scoreboard players set #rtwrapper.installed vortaforge.gate 0
scoreboard players set #rtwrapper.expected vortaforge.gate 1
scoreboard players set #rtwrapper.version vortaforge.gate 0
execute if score #rtwrapper.installed vortaforge.gate <= #rtwrapper.expected vortaforge.gate run scoreboard players set #rtwrapper.version vortaforge.gate 1
execute if score #rtwrapper.version vortaforge.gate matches 1 run scoreboard players operation #rtwrapper.installed vortaforge.gate = #rtwrapper.expected vortaforge.gate
execute if score #rtwrapper.version vortaforge.gate matches 0 if score #rtwrapper.gate.1 vortaforge.gate matches 0 run scoreboard players set #rtwrapper.version vortaforge.gate 1
function rtwrapper:gate/refresh
execute if score #rtwrapper.version vortaforge.gate matches 0 run tellraw @a {"text":"[rtwrapper] This world was saved with a newer version of this datapack. rtwrapper stays inactive (version gate).","color":"red"}
execute if score #rtwrapper.version vortaforge.gate matches 1 unless score #rtwrapper.gate.2 vortaforge.gate matches 0 unless score #rtwrapper.permit vortaforge.gate matches 1 run function rtwrapper:gate/permit_prompt
