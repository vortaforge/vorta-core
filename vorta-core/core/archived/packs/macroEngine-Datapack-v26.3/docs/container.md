# api/container — slot and inventory helpers

Works on container blocks at absolute coordinates. Input is read from `macroengine:input`
(`x`, `y`, `z`, plus `slot` / `slot2` / `tx ty tz` where noted); results go to
`macroengine:output container`. Numbers are checked as numbers before any macro line runs.
Close the module with `function macroengine:api/toggle/container/false`.

| Function | What it does |
|---|---|
| `api/container/info` | One-call summary: `{ok, size, used, free, empty, full, first_free}` |
| `api/container/is_empty` | Condition: no items at all |
| `api/container/is_full` | Condition: every slot occupied (optional `size` for unknown blocks) |
| `api/container/slot_get` | Reads one slot into `container.item` |
| `api/container/slot_set` / `slot_clear` / `slot_swap` | Writes, clears or swaps slots |
| `api/container/slot_is_empty` | Condition: one slot is empty |
| `api/container/transfer` | Hopper-like move of one stack into another container |

```mcfunction
data modify storage macroengine:input x set value 10
data modify storage macroengine:input y set value 64
data modify storage macroengine:input z set value -5
function macroengine:api/container/info
# macroengine:output container -> {ok:1b,size:27,used:3,free:24,empty:0b,full:0b,first_free:0}
```

`used` counts occupied slots, not items; a partly filled stack is one used slot. `first_free` is the
lowest empty slot, or `-1` when the container is full. A double chest reports one half (27 slots).
