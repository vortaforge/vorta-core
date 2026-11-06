# Third-Party Licenses

macroEngine's own code is released under the Unlicense (see `LICENSE`).
The component below is third-party work and stays under its own license.
Keep this file in every distributed copy of the pack (MIT requires the
copyright and permission notice to ship with copies or substantial portions).

## PlayerAction — Michael Weatherby (GitHub: ICY105)

- Upstream: https://github.com/ICY105/PlayerAction
- Copyright holder: Michael Weatherby. `ICY105` is only the GitHub account that hosts the repository.
- License: MIT (verified against upstream `LICENSE`, "Copyright (c) 2022 Michael Weatherby")
- Status: **current dependency, scheduled for removal.** A phased, independent rewrite plan
  exists for `core/internal/player/` — see `playeraction-rewrite-plan.md` (pack root). This section
  is deleted together with the dependency; once no distributed copy of the pack contains
  PlayerAction code, this file only needs the "Not third-party" notes below.

### License text

MIT License

Copyright (c) 2022 Michael Weatherby

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## Not third-party (listed for clarity)

- Minecraft vanilla registries, tags and command syntax are referenced, not
  redistributed. No Mojang assets are included in this datapack.
- Companion resource pack (`macroEngine-Resourcepack-v26.3`) is a separate
  artifact and must carry its own license file.
