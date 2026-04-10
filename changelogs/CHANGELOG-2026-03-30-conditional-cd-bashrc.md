# Conditional cd in .bashrc

**Date:** 2026-03-30
**Status:** [setup]

## Goal

Keep a fallback starting directory for new interactive shells without overriding explicitly selected launch folders from terminal apps like AgentDeck or WezTerm.

## Changes

In `~/.bashrc`, replaced the unconditional `cd /mnt/d/labs` near the top with:

```bash
if [ "$PWD" = "$HOME" ]; then
  cd /path/to/your/projects
fi
```

This only changes directory when the shell opens in `$HOME`. If a terminal app passes an explicit working directory, it is preserved.

## Watch-outs

- The unconditional `cd` was the root cause of AgentDeck sessions landing in the wrong folder.
- `OLDPWD` exposed the issue: it showed the correct launch dir before `.bashrc` moved it.
- The path in the setup guide uses a placeholder (`/path/to/your/projects`) — adapt per machine.

## Replaced

This approach was replaced on 2026-04-10. The correct place to set the starting directory is `config.default_cwd` in `.wezterm.lua` — no `.bashrc` workaround needed. See `changelogs/CHANGELOG-2026-04-10-default-cwd-wezterm.md`.
