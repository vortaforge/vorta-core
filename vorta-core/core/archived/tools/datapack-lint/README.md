# Datapack and resource-pack lint

`scripts/lint_datapacks.sh` runs two static checks: the pinned Spyglass
Minecraft language server (0.4.70), and a separate strict UTF-8/JSON parser
for `.json` and `.mcmeta` files. The latter is necessary: in a negative
control, Spyglass published an empty diagnostic list for malformed JSON.
Neither check starts a Minecraft server or proves in-game behaviour. The
client code is released under the Unlicense; principal dependency notices are in
[`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).

## Setup and use

Node.js 20+ and npm are required. From the repository root:

```sh
npm ci --prefix scripts/datapack_lint --ignore-scripts --no-audit --no-fund
bash scripts/lint_datapacks.sh
# Optional: lint one pack root, for example during development:
bash scripts/lint_datapacks.sh --project packs/DailyBonus
npm test --prefix scripts/datapack_lint
```

Gradle's `lintDatapacks` and `testDatapackLint` install the locked dependencies
as needed. The unit tests load the production language-server session and
exercise the Node JSON-RPC streams, but do not run Spyglass or scan packs.
Dependency updates should also pass `lintDatapacks`: in particular,
`vscode-jsonrpc@10.0.0` exports `vscode-jsonrpc/node`, not `node.js`.
`npm ci` replaces **this tool's generated `node_modules`**; do not store
personal files there. No npm lifecycle scripts are run. Spyglass
fetches Minecraft version data and vanilla archives from `api.spyglassmc.com`
and caches them on disk. A first run requires network access; cached results
may be usable offline. Those external data are not pinned by the npm lock and
may change. Treat them and the dependency supply chain as untrusted inputs and
run quality tooling without privileged credentials.

The default run recursively discovers `pack.mcmeta` roots containing
`data/` or `assets/` under `packs/` and `examples/`, including nested packs
and resource packs. Per root it checks the `.mcfunction`, `.mcmeta`, `.snbt`,
`.mcdoc`, and `data/`/`assets/` JSON files discovered by the wrapper. It
requires a completed language-server project analysis and a diagnostics
notification for each non-excluded candidate. Missing notifications, an
incomplete/cancelled scan, a timeout, a server crash, or missing dependencies
are **failures**, not green results. Build output, hidden directories,
`node_modules` and symlinks are not followed; a symlink in the input tree
causes a failure rather than a silent omission.

The language server chooses **one** Minecraft version from each pack's
metadata. It does not test every version in a `supported_formats` range;
for example, it can choose the newest supported version rather than the
pack's older base version. Static lint does not verify resource resolution in
all loading combinations, macro expansion with real inputs, permission
configuration, performance, or game behaviour. Inspect warnings and review
compatibility separately. The 2026-10-30 full-run warnings and unresolved
risks are documented in [`docs/static-analysis-findings-2026-10-30.md`](../../docs/static-analysis-findings-2026-10-30.md).

## Explicit exceptions

- `allowlist.json` identifies the Ward-only test directories. Their
  non-vanilla commands are excluded from Spyglass diagnostic enforcement and
  the number of excluded files is printed. Ward itself requires its isolated
  CI-only server and must not be run locally. No claim is made that Ward ran.
- Two RTWrapper datapacks contain five pre-existing administrative wrapper
  functions apiece. Spyglass's default assumed permission level is 2, while
  those commands require levels 3 or 4. For **only those exact paths and
  SHA-256 file contents**, the matching permission diagnostic is printed as a
  warning. Other errors still fail. If a file changes, its exception stops
  matching and requires a deliberate review. These warnings do not grant
  permission or prove the functions work on a server.
- Warnings and hints do not fail the default gate. `LINT_WARN_ONLY=1` makes
  diagnostic errors advisory for one run; it does **not** suppress missing
  dependencies, timeouts or incomplete analysis. Do not use advisory mode to
  claim a passing enforced gate.

Spyglass's unmaintained transitive `decompress` dependency has known archive
extraction vulnerabilities, including CVE-2026-53486. `package.json` replaces
it with the maintained `@xhmikosr/decompress` 11.1.4 via an npm override; this
version also addresses the later symlink-chain bypass. The wrapper checks the
resolved package identity and version at runtime, and the offline test suite
includes an escaping-symlink archive regression. Review the override and run
`npm audit` when updating dependencies; an audit is a point-in-time check,
not a guarantee of safety. Spyglass currently requests archive entries in
memory, but retaining the patched implementation is defense in depth.
