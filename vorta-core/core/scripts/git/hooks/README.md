# scripts/git/hooks/

> [!IMPORTANT]
> **The hooks are off by default.** Nothing is blocked until `git config core.hooksPath scripts/git/hooks` has been run. Even then `git commit --no-verify` bypasses them, which is why the real gate is CI, not the hook.

Versioned git hooks. Git does not read hooks from this directory unless you
point it there:

```bash
git config core.hooksPath scripts/git/hooks
```

| Hook | Runs | Refuses |
|---|---|---|
| `pre-commit` | every `git commit` | new/edited datapack content, revival of archived tooling, blocklisted commit identities |
| `pre-push` | every `git push` | the same rules across the pushed range, plus force-pushes to protected branches and commits authored/committed by blocklisted accounts |

Both call `scripts/repo/datapack_guard.py`; neither contains policy of its own.
`git commit --no-verify` and `git push --no-verify` bypass them, which is why
the identical checks run in CI (`datapack-guard` job) — a bypassed hook is
caught there.
