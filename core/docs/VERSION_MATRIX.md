# Supported versions

What each Gradle subproject actually targets, taken from its
`gradle.properties` and `build.gradle` rather than from intent. A test
(`scripts/tests/test_repository_safeguards.py::VersionMatrix`) fails when this
file and the build files disagree, so it cannot drift silently.

## Matrix

| Project | Minecraft | Fabric loader | Loom | Status |
|---|---|---|---|---|
| `mods/afk-manager` | 1.21.1 | 0.16.14 | 1.15.5 | Supported |
| `mods/join-throttle` | 1.21.1 | 0.16.14 | 1.15.5 | Supported |
| `examples/opmod-example` | 26.3 | 0.19.5 | 1.15.5 | Example, not shipped |
| `mods/TEMPLATE-MOD` | 26.1.2 | 0.19.2 | 1.15.5 | Scaffold, not shipped |

## What this means

- **Two supported Minecraft targets, not one.** `afk-manager` and
  `join-throttle` build for 1.21.1. The example targets a snapshot line. There
  is no single "the version this repo supports".
- **A 1.21.3 client or server is not a supported target for either mod.** They
  are compiled against 1.21.1 and no compatibility work has been done for
  1.21.3. Running them there is untested, not impossible.
- **Loom is one pinned release (1.15.5) everywhere**, including the template.
  A `-SNAPSHOT` in the template meant CI could compile against different build
  tool code on different days for an unchanged commit.

## Changing a version

1. Edit the project's `gradle.properties` (and `build.gradle` if the plugin
   version lives there).
2. Update this table in the same commit.
3. Run `python3 -m unittest discover -s scripts/tests` — the matrix test
   compares this document against the files and fails on a mismatch.

Do not add a `-SNAPSHOT` or `+` version anywhere in `mods/` or `examples/`.
The build cannot be reproduced from the commit if it does, and the template is
compiled by CI like any other subproject.

## Not covered

- No CI job builds the mods on more than one Minecraft version. The matrix is
  a statement of intent verified against the build files, not a build result
  for each line.
- Nothing here has been run in a live Minecraft server; the repository
  forbids local server tests.
