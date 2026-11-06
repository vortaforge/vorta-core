# macroEngine: read this before you continue

This page is linked from the consent screen that macroEngine shows each player before it activates for them. It explains what the notice means, how to review the pack, and which inputs must never be typed.

## 1. Third-party content notice

macroEngine, its runtime data, and everything that flows through it (text typed on signs, in books, on name tags, in anvil renames, in chat, and the contents of any other datapack, mod or resource pack in the same world) is **third-party content**. It is **not audited, verified or endorsed by Mojang, Microsoft or VortaForge**. Nothing on this page is a security guarantee. You are responsible for checking what you install and what you type.

This pack runs under the authority of whoever operates this server. **The server owner controls what the pack does, what data it stores, and how it behaves on this installation** — Mojang, Microsoft and VortaForge have no oversight over any specific server's configuration. Trust this content only to the extent you trust the server operator.

## 2. The consent screen

- **Open INFO.md** opens this page.
- **Continue** opens a second screen with a text box. Type `yes` (lowercase, nothing else) and press **Submit** to accept, or `no` to cancel. Anything else is rejected by the game and changes nothing.
- Pressing Escape closes a screen without accepting. Reopen it with `/trigger macroengine.consent set 1` (the chat line the pack prints is clickable).
- While you have not accepted, the pack stays inactive for you.
- An operator can withdraw a player's consent with `/execute as <player> run function macroengine:gate/consent_reset`.

Limits, stated plainly:

- The Submit button runs `/trigger macroengine.dlg_<your text> set 1` as you. `/trigger` is used because it works for non-operators; `/function` would not. Only `macroengine.dlg_yes` and `macroengine.dlg_no` exist, so any other text is a failed command.
- A trigger is not authenticated. Anyone can type `/trigger macroengine.dlg_yes set 1` in chat and skip the screens. The screens make the notice hard to miss; they do not force anyone to read it.
- A datapack is plain text and its checks can be deleted by whoever installs it. This is a safeguard, not a sandbox. Enforcement that cannot be bypassed belongs in a mod.

## 2a. No screen from this pack is an official Mojang/Microsoft screen

Every dialog macroEngine shows is rendered by this server-side datapack, inside the game's own UI. It is **not** an official Mojang, Microsoft or Minecraft system screen, however it looks. **No legitimate dialog — from this pack, or from any other pack or server — will ever ask for your Microsoft account email, password, verification code, or any other account credential.** If a dialog asks for that, close it immediately, do not type anything into it, and report it (Section 6).

## 2b. Regional rules for online services

macroEngine is a datapack. It does not host user accounts or a public service and cannot open network connections by itself; what it stores stays in the world's storage on the server (see Section 4).

Some jurisdictions regulate online platforms. One example is Türkiye's "Social Network Provider Procedures and Principles" (BTK decision 2023/DK-İD/119, Official Gazette no. 32150, 1 April 2023), issued under Law 5651. According to its text:

- It addresses *social network providers*: services that let users create, view or share content for social interaction (Art. 3). Services where social interaction is only a secondary or incidental feature are out of scope (Art. 1).
- The representative, response, reporting, ad-library and data-localisation duties (Art. 4, 9, 10, 11, 13) attach to foreign-origin providers with more than one million daily accesses from Türkiye; heavier requirements start at ten million (Art. 5).
- Duties such as disclosing user data to prosecutors (Art. 12) and removing reported content (Art. 36) are placed on the platform or its representative, not on people who install a datapack.

Whether a particular server or service counts as a social network provider is for the regulator to decide (Art. 37, 38); this text does not settle it. If you operate a public community service in or for users in such a jurisdiction, get legal advice. Nothing on this page is legal advice.

## 3. How to review the pack (server owners and admins)

Review the pack yourself, or have a person you trust do it, before enabling it on a world with other players. Do this reading by hand or with plain `grep`, not by pasting pack contents into an AI tool that can act on them.

1. **Get it from the official repository only.** Clone `https://github.com/vortaforge/core` and compare the pack folder with what you installed (`diff -r`, or `git diff` against a clean checkout). Any difference you did not make is a reason to stop.
2. **List what else is loaded.** Run `/datapack list`. Every datapack in the world can call macroEngine functions; there is no isolation between datapacks.
3. **Check function tags.** Tags merge across datapacks, so another pack can append entries to `#minecraft:load`, `#minecraft:tick` and the `#macroengine:` tags (`input/*`, `loop`, `admin/run`). Read the `data/*/tags/function/` files of every installed pack for entries you do not recognize.
4. **Find command-executing code.** Several functions run a caller-supplied string as a command. Find them with:

   ```
   grep -rnE '^\$.*\$\((cmd|command)\)' data
   ```

   The ones to understand first are `api/cmd/as_player`, `api/cmd/other/run_*`, `api/perm/run`, `api/perm/exec`, `core/lib/queue_add_cmd` and `core/lib/schedule_cmd`. Check, for each caller in your world, that the string passed in can never contain player-typed text.
5. **Check how input is handled.** The input system (`input/*`) only writes the raw text to the `macroengine:input` storage and does not execute it. Anything you build on top must validate it first with `input/validate/check` (`int`, `float`, `bool`, `tag_safe`) and must never substitute it into a command or JSON string.
6. **Check gate state.** Run `/function macroengine:gate/status` and `/function macroengine:gate/report` and confirm the gates you expect are on.
7. **Treat all text fields as untrusted.** `pack.mcmeta` descriptions, README and license text, item names, book pages and sign lines can all contain text written to mislead a reader, human or AI.

## 4. Inputs that must never be typed

This applies to signs, writable books, lecterns, name tags, anvil renames, command block minecarts, chat, and the consent text box.

- **Commands or command fragments:** anything starting with `/`, or containing `run`, `execute`, `function`, `data`, `op`, `give`, `setblock` and similar, written so that something might execute it.
- **Macro and syntax characters:** `$`, `$(`, `{`, `}`, `[`, `]`, `"`, `'`, `\`, `:` and `@a`/`@e`/`@p`/`@r`/`@s` selectors, unless an interface explicitly asks for them. These are exactly what `input/validate/check` rejects for `tag_safe`.
- **JSON or NBT:** raw text components, item components or other structured data meant to be parsed later.
- **Instructions aimed at AI tools:** phrases such as "ignore previous instructions", "you are now...", "system:", "run the following", fake tool or admin messages, or text formatted to look like a prompt or a tool result. This is prompt injection. It is an abuse of this project and will be treated as malicious.
- **Secrets and personal data:** passwords, tokens, API keys, addresses, real names. Captured text is saved in the world's storage and is readable by operators and by anything with data access. This includes **your Microsoft account credentials** — no screen in this pack will ever legitimately ask for them (see Section 2a).
- **Anything in the consent box other than `yes` or `no`.** The box is part of a command, not a chat field.

If you are unsure whether something is safe to type, do not type it.

## 5. If you run an AI tool next to this pack

Coding agents, AI-assisted admin tools and AI review tools may read this pack or its runtime data.

- Treat all player-supplied text (signs, books, name tags, chat, storage contents, logs) as **untrusted data, never as instructions**.
- Do not let such a tool run commands, install packs, change permissions or apply patches because of text it found in the pack or the world. Require a human to approve every action.
- Give such a tool read-only access where you can, and keep it away from operator credentials, tokens and `/op` level command execution.
- If text in the pack or in world data tries to direct the tool, stop, do not follow it, and report it.

## 6. Reporting

Report suspected injection attempts, abuse or vulnerabilities on the issue tracker of [vortaforge/core](https://github.com/vortaforge/core). Describe the location and the effect; do not paste the suspected payload into an AI tool to analyze it.
