# wezterm — terminal experience repo

The complete terminal setup as real, running code: one sectioned WezTerm config (`wezterm.lua`), a captured fish shell layer (`shell/`), an oh-my-posh prompt theme, and small CLI tools. The repo checkout *is* the live config — WezTerm reads it via the `WEZTERM_CONFIG_FILE` env var, fish reads it via symlinks, and `git pull` is the whole sync story. Per-machine values, theme choice, and cross-cutting drop-ins are isolated into three seams (`machine.lua`, `theme.lua`/`themes/`, `plugins/`) so the tracked code is identical on every machine.

**Scope rule:** this repo owns the terminal experience — emulator, shell, prompt, look-and-feel tools, including adapters that recolor other apps from the master theme (`integrations/`). Sibling repos own integrations with other products (e.g. claude-waiting-notification, claude-parallel-sessions) and plug in through `plugins/`.

## Feature tour

| Feature | Where |
|---|---|
| Themes & switching (cyberdream, paper, tokyo-night) | `themes/*.lua`; select via `theme.lua` one-liner, auto-reloads |
| Fonts & switching/cycling (Maple default) | `fonts/*.lua`; select via `font.lua` / `font` command, cycle with `Alt+F` / `Alt+Shift+F`; `shell/fonts.fish` fetches binaries |
| Theme application (colors, tab bar style, background, decorations) | `wezterm.lua` — THEME APPLICATION section |
| Tab title styling + plugin overlay chain | `wezterm.lua` — TAB TITLE section |
| Pane splitting / navigation / modal resize, cwd inheritance | `wezterm.lua` — KEYBINDINGS + KEY TABLES sections |
| Mouse: right-click paste, Ctrl+drag window move, Ctrl+click links | `wezterm.lua` — MOUSE section |
| Right status bar (distro, git branch, clock, mode indicator) | `wezterm.lua` — RIGHT STATUS section |
| Per-machine values | `machine.sample.lua` (Lua side), `shell/fish/machine.sample.fish` (fish side) |
| Plugin seam for sibling repos | `plugins/README.md` (contract; contents gitignored) |
| Fuzzy `cd` picker (fzf + fd) | `shell/fish/functions/cd.fish` + `conf.d/40-smart-cd.fish` |
| `theme` command (list/switch the master theme, tab-completed) | `shell/fish/functions/theme.fish` + `completions/theme.fish` |
| eza/bat aliases, OSC 7 + git-branch integration | `shell/fish/conf.d/` |
| Prompt | `shell/oh-my-posh/theme.omp.json` via `conf.d/30-oh-my-posh.fish` |
| Fish install / tool doctor | `shell/install.fish`, `shell/doctor.fish` |
| Master-theme propagation to Claude Code (TUI theme + statusline colors) | `integrations/claude-code/` |
| Themed markdown/report viewer (`view <file>` + Ctrl+Alt+/ dock) | `../wezterm-webview/` (sibling repo) |

Strangers cherry-pick by copying a section or snippet — every section is working code with its rationale in comments.

## Getting started

- [`setup.md`](setup.md) — fresh-machine install, sync, uninstall.
- [`docs/verify-checklist.md`](docs/verify-checklist.md) — behavioral verification.
