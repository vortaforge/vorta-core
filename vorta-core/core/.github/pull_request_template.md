
> [!IMPORTANT]
> **Before opening a pull request:** make sure it adds no datapack content. If it does, the `datapack-guard` CI job fails and the pull request is closed.

## 📝 Description
<!-- Briefly describe the changes introduced in this PR. Why is this change necessary? -->

## 📦 Affected Scope / Packages
<!-- Select all affected areas within the monorepo -->
- [ ] Core / Shared Libraries
- [ ] Datapacks (`packs/`)
- [ ] Fabric Mods / Services
- [ ] Tooling / CI/CD (`.github/`, Gradle scripts, etc.)
- [ ] Documentation / Specs

## 🔗 Related Issues
<!-- Link relevant issues or discussions (e.g., Closes #123, Fixes #456) -->

## 🧪 Type of Change
- [ ] 🐛 Bug fix (non-breaking change fixing an issue)
- [ ] ✨ New feature (non-breaking change adding functionality)
- [ ] 💥 Breaking change (fix or feature causing existing code to fail)
- [ ] 🛠️ Refactoring / Performance optimization
- [ ] ⚙️ CI/CD / Automation / Dependencies
- [ ] 📚 Documentation update

## 🧪 Verification & Testing
<!-- Describe how these changes were verified. Do not claim a check ran if it did not. -->
- [ ] Canonical CI graph passes (`./gradlew ci -PconfirmZip=yes`), or the exact narrower command that ran is named below
- [ ] Local environment/runtime tests completed, or explicitly marked as not run below
- [ ] No regression or unexpected side effects detected in dependent packages

## 👀 Review status
<!-- Be explicit about whether an independent review is actually expected. -->
- [ ] A reviewer with write access (a code owner where CODEOWNERS applies) has been requested
- [ ] No independent reviewer is available; a maintainer ruleset bypass may be used, and this PR must be described as **not independently reviewed (Anti-Review)**, never as approved
- [ ] This change touches `.github/workflows/` or another security-sensitive surface and the added permissions, triggers and code-execution paths are explained above

## ✅ Checklist
- [ ] Code complies with project style and architectural guidelines.
- [ ] Changes are isolated to the intended scope within the monorepo.
- [ ] Relevant documentation or specs have been updated.
- [ ] `git diff --check` passes and no generated files, credentials or patch files are included.
