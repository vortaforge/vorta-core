# api/cb — command-block callbacks

Run a command string through a temporary command block, now or later.

| Function | Input (`macroengine:input cb`) | Output |
|---|---|---|
| `api/cb/run` | `cmd`, optional `x` `y` `z` | — |
| `api/cb/run_delayed` | `cmd`, `delay` (ticks, min 1), optional `x` `y` `z` | `macroengine:output cb_id` |
| `api/cb/run_sequence` | `cmds` (list), optional `interval` (default 2), `x` `y` `z` | `macroengine:output cb_id` (one id for the whole sequence) |
| `api/cb/run_repeating` | `cmd`, `times` (1..100), optional `interval` (default 2, min 1), `x` `y` `z` | `macroengine:output cb_id` (one id for all runs) |
| `api/cb/time_left` | `id` | `macroengine:output cb_time_left` (ticks until the next entry of that id, -1 if none), `cb_pending` (entries still queued) |
| `api/cb/cancel_id` | `id` (the `cb_id` you got back) | `macroengine:output cb_cancelled` (entries removed, 0 if already fired) |
| `api/cb/cancel` | — | clears the whole queue |
| `api/cb/queue_size` | — | score `#cb_queue_size macroengine.tmp` |
| `api/cb/list` | — | prints the queue to the executor |

```mcfunction
data modify storage macroengine:input cb set value {cmds:["say one","say two","say three"],interval:20}
function macroengine:api/cb/run_sequence

# how long until the next step?
data modify storage macroengine:input cb.id set from storage macroengine:output cb_id
function macroengine:api/cb/time_left

# changed my mind: drop whatever has not fired yet
data modify storage macroengine:input cb.id set from storage macroengine:output cb_id
function macroengine:api/cb/cancel_id
```

Repeat one command (five runs, one second apart):

```mcfunction
data modify storage macroengine:input cb set value {cmd:"say tick",times:5,interval:20}
function macroengine:api/cb/run_repeating
```

## Behaviour notes

- **Quotes are fine in `cmd`.** The command is copied from storage into the block, not
  pasted into a macro line, so `say "hi"` works.
- **Fire spacing.** Entries share one temporary command block, and a second one placed
  too soon would overwrite the first before it ran. After an entry fires, anything else
  that is ready is pushed back by one tick, so fires are at least 2 ticks apart. A
  `run_sequence` with `interval:1` therefore runs at an effective interval of 2.
- **Ids.** `cb_id` is assigned by the engine (1, 2, 3 …) and compared as a number, so a
  caller-supplied value is never pasted into a command.
- The queue is cleared on `/reload`; ids restart with the next push.
