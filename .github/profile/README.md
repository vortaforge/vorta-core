# VortaForge

VortaForge brings together Fabric mods, Minecraft datapacks and the tooling used
to build and maintain them. The projects are independent community work, not an
official Minecraft product and not affiliated with or endorsed by Mojang or
Microsoft.

## Start here: the main repository

[**vortaforge/core**](https://github.com/vortaforge/core) is the consolidated
monorepo. Start with its README and the README for the particular component:
versions, dependencies, installation steps and support status differ between
projects.

| Area | What you will find |
| --- | --- |
| [`mods/`](https://github.com/vortaforge/core/tree/main/mods) | Fabric-mod projects, including `datapack-blocker`, `afk-manager` and `join-throttle`. |
| [`packs/`](https://github.com/vortaforge/core/tree/main/packs) | Datapacks, including TunnelScript, macroEngine, guikitfw, DailyBonus and QuickShare. RTWrapper also has a Fabric component under `packs/RTWrapper/`. |
| [`scripts/`](https://github.com/vortaforge/core/tree/main/scripts) | Development helpers, including datapack linting, release building, datapack generation and GUI-generation tooling. |
| [`examples/`](https://github.com/vortaforge/core/tree/main/examples) | Templates and example projects. |

Not every component is necessarily compatible with every Minecraft or Fabric
version. Check the selected component's documentation and release artifacts
before installing it, and keep a backup of worlds or servers before testing
changes. Legacy or archived components may not be actively supported.

## Get help or contribute

- **Questions and ordinary bugs:** read the component README, search existing
  issues, and then open an issue in the affected repository with the relevant
  version and reproduction details. See the default
  [support guidance](https://github.com/vortaforge/.github/blob/main/SUPPORT.md).
- **Contributions:** read the affected project's guidance and the default
  [contribution guide](https://github.com/vortaforge/.github/blob/main/CONTRIBUTING.md).
  Discuss larger changes first, preserve license and origin notices, and say
  which checks you ran and which you could not run.
- **Security vulnerabilities:** do not open a public issue or publish exploit
  details. Follow the [security policy](https://github.com/vortaforge/.github/blob/main/SECURITY.md)
  and report privately; if private reporting is unavailable, first establish a
  private channel with a maintainer.
- **Community conduct:** follow the
  [Code of Conduct](https://github.com/vortaforge/.github/blob/main/CODE_OF_CONDUCT.md).

Project-specific policies may add requirements or replace the corresponding
organization defaults. The volunteer maintainers cannot guarantee a response
time or support for frozen and archived projects.

## Maintainer handover

A maintainer handover is being prepared; it has **not** been completed. The
current maintainer remains responsible until a successor explicitly accepts and
the checklist in [`core/HANDOVER.md`](https://github.com/vortaforge/core/blob/main/HANDOVER.md)
is complete. The process includes reviewing access, credentials, settings,
billing and releases; an invitation or an old transfer note is not proof that
ownership or credential cleanup has already happened. See the dated
[transfer record and its updates](https://github.com/vortaforge/.github/blob/main/TRANSFER.md).

## Origin and licensing

This work originated as [`runtoolkit/suite`](https://github.com/runtoolkit/suite)
by **Runtoolkit**; earlier project history also includes the Runtoolkit and
vortacraftmc organizations. Preserve original copyright and attribution
notices, and inspect the relevant component's `LICENSE`, `NOTICE` or other
terms before use or redistribution.
