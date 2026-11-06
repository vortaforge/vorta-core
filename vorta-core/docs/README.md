# vortaforge/docs

Complete documentation for VortaForge, published at
**https://vortaforge.github.io/docs/**.

Everything in one place: the two live Fabric mods, the archived and disarmed
datapacks, the in-pack gate and the warning that now links here, plus references
for the API, the version matrix and the rules a maintainer has to follow.

## Read it

| Page | What it covers |
|---|---|
| [Home](https://vortaforge.github.io/docs/) | Everything, organised by audience |
| [Pack warnings](https://vortaforge.github.io/docs/docs/warnings.html) | Why the datapacks are archived, what "disarmed" enforces, how the gate works, and why some packs cannot show a clickable link |
| [API reference](https://vortaforge.github.io/docs/docs/api.html) | Mod commands, every settings field, the datapack interop contract, and the `click_event` rename |
| [Version matrix](https://vortaforge.github.io/docs/docs/versions.html) | Per-project Minecraft / loader / Loom versions and the rules that keep them honest |
| [Mod guides](https://vortaforge.github.io/docs/mods/) | afk-manager and join-throttle, end to end |
| [Maintainer guide](https://vortaforge.github.io/docs/docs/maintainers.html) | The guard, the gates, the release flow, the archive rules |
| [Archive register](https://vortaforge.github.io/docs/docs/archive.html) | Every archived project, its status and why it was archived |

## Why this page exists separately

The in-game warnings added to the archived datapacks link to
`docs/warnings.html` on this site. A warning that points at a dead URL is worse
than no warning, so the link target is a stable, versioned path with no redirects.

## Structure

```
index.html              landing page
docs/warnings.html      the warning target for every in-pack message
docs/api.html           API and configuration reference
docs/versions.html      version matrix
docs/maintainers.html   maintainer rules
docs/archive.html       generated from core's archived/archive.json
mods/index.html         mod guide index
mods/afk-manager.html
mods/join-throttle.html
assets/                 reserved; pages currently inline all CSS
```

## Editing

The site is hand-written HTML with inline CSS and no build step. That is a
deliberate choice, not laziness:

- No framework means nothing breaks three years from now because a toolchain
  moved, and no dependency needs auditing for a read-only docs site.
- Inline CSS means the pages render correctly in sandboxed previewers that have
  no network access, which is exactly where these files get reviewed.

Two rules the deploy workflow enforces, so a broken page cannot ship:

1. **No external assets.** No CDN stylesheet, font, or script. A `src=` pointing
   at another host fails the build.
2. **Every internal link must resolve.** A relative `href` that does not exist
   on disk fails the build.

Run the same check locally before pushing:

```bash
python3 - <<'PY'
import pathlib, re, sys
pages = sorted(p for p in pathlib.Path(".").rglob("*.html") if ".git" not in p.parts)
bad = []
for page in pages:
    text = page.read_text(encoding="utf-8")
    for m in re.finditer(r'href=["\']([^"\'#?]+)(?:[#?][^"\']*)?["\']', text):
        t = m.group(1)
        if t.startswith(("http://", "https://", "mailto:", "#")):
            continue
        target = page.parent / t
        if t.endswith("/"):
            target = target / "index.html"
        if not target.resolve().exists():
            bad.append(f"{page}: broken -> {t}")
print(f"ok: {len(pages)} pages" if not bad else "FAILED")
[print("  ", b) for b in bad]
sys.exit(1 if bad else 0)
PY
```

## Licence

Unlicense, same as the rest of VortaForge. See
[`vortaforge/core`](https://github.com/vortaforge/core).
