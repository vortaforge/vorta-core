# Multi-action entry point. Mirrors api/run.mcfunction, but for a batch of actions instead
# of one: set rtwrapper:api batch to an array of {cmd:...,params:{...}} objects, then
# /function rtwrapper:api/run_batch. Every action in the array is enqueued (in order, tagged
# with a shared batch_id) and then the normal immediate-drain runs, so all of them execute
# before this function returns, same as api/run.mcfunction does for a single action.
execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
function rtwrapper:api/enqueue_batch
function rtwrapper:core/run/run_actions
