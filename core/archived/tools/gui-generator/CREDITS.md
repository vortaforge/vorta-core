# Credits

## AI-assisted changes

Parts of guigenmc were written with AI assistance. This file lists them so the
involvement is visible to everyone, independent of git commit authorship.

| Change | AI involved | Human review |
|--------|-------------|--------------|
| Pack-scoped scoreboards / triggers / `custom_data` (multi-datapack conflict fix): `models.obj`, `generators/*`, `components.py`, `static/index.html` JS port, `cli.py` hints, `tests/test_pack_isolation.py` | Claude (Anthropic), Claude.ai chat, Oct 2026 | Pending — maintainer must review and test in-game before release |
| Browser UI JS port (`static/index.html`) brought to byte-identical parity with the Python generator (triggers, weather predicates, on_open/on_close, layouts, boats, item components, validation) + `tests/test_ui_parity.py`; also fixed an invalid unquoted `minecraft:custom_data` NBT key in the dropped-item `kill` selector introduced by the first change | Claude (Anthropic), Claude.ai chat, Oct 2026 | Pending — maintainer must review and test in-game before release |

Not verified in a running Minecraft server: the generated functions were only
checked by the test-suite and by comparing generator output, not executed in-game.
