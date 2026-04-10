# Fix default starting directory for new windows and tabs

**Date:** 2026-04-10
**Status:** [setup]

## Goal

Ensure new WezTerm windows and new tabs both open in `~/source/local` instead of the WSL home or the Windows home directory.

## Why

`config.default_cwd` is a global WezTerm setting that does not work reliably for WSL domains. WezTerm launches WSL as a Windows subprocess; WSL either ignores the CWD passed by WezTerm or falls back to the Windows process's working directory. This caused two separate symptoms:

- **New windows** started in the WSL home (`/home/akash`) — WSL ignored `default_cwd`.
- **New tabs** (`SpawnTab("CurrentPaneDomain")`) started in the Windows home (`/mnt/c/Users/AkashJohny`) — a fresh WSL process spawned with no inherited CWD defaults to the Windows working directory.

Two fixes were needed:

1. **New windows**: Use `config.wsl_domains` with `default_cwd` — the domain-level setting that WezTerm actually uses when spawning into WSL.
2. **New tabs**: `SpawnTab("CurrentPaneDomain")` spawns a fresh WSL process and cannot reliably pass the current pane's CWD to it. Switched to `SpawnCommandInNewTab` with an explicit `domain` and `cwd`.

## Changes

In `.wezterm.lua`, replaced:

```lua
config.default_cwd = "/home/akash/source/local"
```

With:

```lua
-- config.default_cwd does not work reliably for WSL domains. Use wsl_domains
-- to set the starting directory at the domain level instead.
-- ADAPT: Set default_cwd to your preferred starting directory.
config.wsl_domains = {
  {
    name = "WSL:Ubuntu-24.04",
    distribution = "Ubuntu-24.04",
    default_cwd = "/home/akash/source/local",
  },
}
```

Also replaced the new tab keybinding:

```lua
-- Before:
{ key = "t", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },

-- After:
{ key = "t", mods = "CTRL|SHIFT", action = act.SpawnCommandInNewTab({
  domain = { DomainName = "WSL:Ubuntu-24.04" },
  cwd = "/home/akash/source/local",
}) },
```

## Also replaces

`changelogs/CHANGELOG-2026-03-30-conditional-cd-bashrc.md` (the `.bashrc` workaround)

## On a new machine

- Change `"WSL:Ubuntu-24.04"` and `distribution` to match your distro name (`wsl.exe -l -q`).
- Change `default_cwd` to your preferred starting directory.

## Verification

Open WezTerm fresh — first tab should start in `~/source/local`. Open a new tab with `Ctrl+Shift+T` — should also start in `~/source/local`.
