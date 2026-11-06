"""The browser UI (static/index.html) ships a JS port of the generator.

It silently drifted behind the Python generator once (no triggers, no weather
predicates, no on_open/on_close, wrong pack format...). These tests run the
embedded JS in Node and require byte-identical output, so drift fails CI.

AI-assisted: written with Claude (Anthropic) — see CREDITS.md.
"""

from __future__ import annotations

import json
import re
import shutil
import subprocess
import tempfile
from pathlib import Path

import pytest

from guigenmc.generators import generate_datapack
from guigenmc.models import load_menu_from_file
from guigenmc.validate import validate_menu

ROOT = Path(__file__).resolve().parent.parent
HTML = ROOT / "guigenmc" / "static" / "index.html"
EXAMPLES = sorted((ROOT / "examples").glob("*.json"))

pytestmark = pytest.mark.skipif(shutil.which("node") is None, reason="node not installed")

EXTRA = {
    "boat": {
        "namespace": "boatns", "menu_id": "b", "display_name": 'Boat "Q"', "layout": "border",
        "default_filler": "minecraft:blue_stained_glass_pane",
        "container": {"type": "boat", "y_offset": 2, "glowing": True, "custom_name_visible": True,
                      "persistence": False, "rotation_yaw": 90},
        "on_open": ["say open"], "on_close": ["say bye"], "follow": False, "distance_close": 10,
        "pages": [
            {"index": 0, "name": "A", "on_enter": ["say enter"], "filler": "minecraft:red_stained_glass_pane",
             "widgets": [{"kind": "button", "slot": 13, "item": "minecraft:stone", "name": {"text": "S"},
                          "commands": ["say s"], "cooldown_ticks": 40, "enchanted": True,
                          "custom_model_data": 7, "count": 3},
                         {"kind": "close", "slot": 22}]},
            {"index": 1, "name": "B", "layout": "top_row", "widgets": [{"kind": "close", "slot": 26}]},
        ],
    },
    "hopper": {
        "namespace": "hop", "menu_id": "h", "container": {"type": "hopper"}, "fill_empty": False,
        "pages": [{"index": 0, "name": "A", "widgets": [
            {"kind": "button", "slot": 2, "item": "minecraft:stone", "name": {"text": "S"}, "commands": ["say s"]},
            {"kind": "close", "slot": 4}]}],
    },
}


def _core_js() -> str:
    html = HTML.read_text(encoding="utf-8")
    scripts = [m.group(1) for m in re.finditer(r"<script(?![^>]*\bsrc=)[^>]*>(.*?)</script(?:\s[^>]*)?>", html, re.S | re.IGNORECASE)]
    js = max(scripts, key=len)
    start = js.index("// guigen core")
    j = js.index("function generateDatapack")
    end = js.index("\n}\n", j) + 3
    validate = re.search(r"^function validateMenu\(.*?^}\n", js, re.S | re.M).group(0)
    return (js[start:end] + "\n" + validate +
            "\nconst fs=require('fs');const m=loadMenuFromJsonString(fs.readFileSync(process.argv[2],'utf8'));"
            "console.log(JSON.stringify({files:Object.fromEntries(generateDatapack(m)),warnings:validateMenu(m)}));\n")


@pytest.fixture(scope="module")
def runner(tmp_path_factory) -> Path:
    p = tmp_path_factory.mktemp("uijs") / "run.js"
    p.write_text(_core_js(), encoding="utf-8")
    return p


def _configs(tmp_path: Path) -> list[Path]:
    out = list(EXAMPLES)
    for name, cfg in EXTRA.items():
        f = tmp_path / f"{name}.json"
        f.write_text(json.dumps(cfg), encoding="utf-8")
        out.append(f)
    return out


def test_js_port_matches_python_generator(runner: Path, tmp_path: Path) -> None:
    for cfg in _configs(tmp_path):
        res = subprocess.run(["node", str(runner), str(cfg)], capture_output=True, text=True, check=True)
        js = json.loads(res.stdout)
        menu = load_menu_from_file(str(cfg))
        py = generate_datapack(menu)
        assert set(js["files"]) == set(py), cfg.name
        for path, text in py.items():
            assert js["files"][path].rstrip() == text.rstrip(), f"{cfg.name}: {path}"
        assert js["warnings"] == validate_menu(menu), cfg.name


def test_dropped_item_kill_uses_valid_quoted_nbt_key() -> None:
    """`minecraft:custom_data` contains ':' so NBT requires it to be quoted."""
    menu = load_menu_from_file(str(EXAMPLES[0]))
    tick = generate_datapack(menu)[f"data/{menu['namespace']}/function/core/tick.mcfunction"]
    assert '{"minecraft:custom_data":{guigen:{widget:1,pack:"' in tick
    assert "components:{minecraft:custom_data" not in tick
