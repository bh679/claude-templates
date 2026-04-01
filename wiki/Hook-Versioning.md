[Home](Home) > [Features](Features) > Hook Versioning

# Hook Versioning

Version tracking system that detects when locally installed hooks are outdated compared to the source in claude-templates.

## How It Works

1. Every hook script declares a `HOOK_VERSION` variable on line 3
2. Install scripts write each hook's version to `.claude/hook-versions.json` in the consumer project
3. `check-hooks.sh` compares installed versions against source versions
4. Symlinked hooks auto-update, but copied hooks (git hooks) go stale

### Checking for Updates

```bash
~/Projects/Claude\ Templates/hooks/check-hooks.sh
```

Output shows which hooks are current and which need updating.

## Technical Notes

- Bump `HOOK_VERSION` whenever hook behaviour changes
- Uses semver: patch for tweaks, minor for new rules, major for breaking changes
- Symlinked Claude Code hooks update automatically on `git pull`
- Copied git hooks require re-running the installer

## Related

- [Enforceable Hooks](Enforceable-Hooks)
- [Drift Detection](Drift-Detection)
- [Versioning Standard](Versioning-Standard)
