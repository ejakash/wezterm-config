# Setup

The repo checkout is the live config. WezTerm reads `wezterm.lua` straight from the repo (env var); fish reads `shell/fish/` through symlinks. There is no copy step, so there is no drift.

## Fresh machine

### 1. Clone to a Windows-visible path

```bash
git clone <repo-url> /mnt/d/labs/wezterm   # i.e. D:\labs\wezterm on the Windows side
```

Any path works as long as Windows WezTerm can read it; adjust the paths below to match.

### 2. Per-machine values (Lua side)

```bash
cp machine.sample.lua machine.lua    # then edit — every field is commented
```

Optionally pick a non-default theme:

```bash
cp theme.sample.lua theme.lua        # edit the one-liner; available themes in themes/
```

Both files are gitignored. `wezterm.lua` refuses to start without `machine.lua` and names the copy step in its error.

### 3. Point WezTerm at the repo

PowerShell (user scope, one-time):

```powershell
[Environment]::SetEnvironmentVariable('WEZTERM_CONFIG_FILE','D:\labs\wezterm\wezterm.lua','User')
```

Fully quit and relaunch WezTerm — env vars don't reach running processes.

**Fallback shim** — if the env var won't take on a machine, put this 3-line `C:\Users\<you>\.wezterm.lua` in place instead:

```lua
-- shim: the real config lives in the repo (WEZTERM_CONFIG_FILE didn't take)
_G.__TERMINAL_REPO_DIR = "D:\\labs\\wezterm"
return dofile("D:\\labs\\wezterm\\wezterm.lua")
```

This machine (the original) uses the env var, not the shim.

### 4. Fish layer

```bash
cp shell/fish/machine.sample.fish ~/.config/fish/conf.d/00-machine.fish   # then edit
fish shell/install.fish    # symlinks conf.d + functions into ~/.config/fish/
fish shell/doctor.fish     # report-only check of the optional tools (see the list at the top of the script)
```

`00-machine.fish` is copied, not symlinked — it's machine-local. `install.fish` is idempotent; pre-existing real files are moved aside to `<name>.pre-repo`, never overwritten. Doctor is report-only; everything degrades gracefully if a tool is missing, so install what you want from its list.

### 5. Verify

Walk [`docs/verify-checklist.md`](docs/verify-checklist.md).

## Sync

```bash
git pull
```

That's it — WezTerm auto-reloads, fish symlinks read the repo directly. The old `synced-on-<hostname>` tag model is retired.

**Drift checkpoint (the one manual step):** per-machine values exist in TWO artifacts — `machine.lua` and `~/.config/fish/conf.d/00-machine.fish`. After pulling, diff your local copies against `machine.sample.lua` and `shell/fish/machine.sample.fish` for new fields, and re-run `fish shell/doctor.fish` in case the tool table grew.

## Uninstall

1. Remove the env var: `[Environment]::SetEnvironmentVariable('WEZTERM_CONFIG_FILE',$null,'User')` (or delete the shim `.wezterm.lua`); restart WezTerm.
2. Delete the 17 fish symlinks (9 in `~/.config/fish/conf.d/`, 6 in `~/.config/fish/functions/`, 2 in `~/.config/fish/completions/` — anything pointing into this repo) plus `00-machine.fish`; restore any `.pre-repo` files by renaming them back.
3. Restore an old config from `.backups/` if wanted. `.backups/` stays gitignored for ad-hoc snapshots; git history is the config backup now.

## See also

Sibling repos that plug into the `plugins/` seam (see `plugins/README.md` for the contract):

- **claude-waiting-notification** — amber tab + pane tint + toast when Claude Code is waiting for input. Install: copy its `claude-waiting.plugin.lua` to `plugins/claude-waiting.lua`, plus its own hook/toast steps. https://github.com/ejakash/claude-waiting-notification
- **claude-parallel-sessions** — fans a Claude Code task into a set of WezTerm panes. https://github.com/ejakash/claude-parallel-sessions
