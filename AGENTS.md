# CLAUDE.md — agent instructions for working in this repo

> `AGENTS.md` mirrors this file for compatibility with non-Claude AI coding harnesses. Keep both files in sync. This file is the primary source of truth.

## What this repo is

The terminal experience as code: one sectioned `wezterm.lua` (the whole WezTerm config), a tracked fish shell layer (`shell/fish/`, symlinked into `~/.config/fish/`), an oh-my-posh prompt theme, and look-and-feel adapters under `integrations/`. Code is the source of truth — what's in git is what runs. Three seams isolate everything that varies:

1. **Machine** — `machine.lua` (Lua side) + `~/.config/fish/conf.d/00-machine.fish` (fish side), both gitignored, copied from tracked samples.
2. **Theme** — data-only tables in `themes/`, selected by the gitignored `theme.lua` one-liner.
3. **Plugins** — `plugins/*.lua` drop-ins from sibling repos, gitignored.

Scope rule: this repo owns the terminal experience (emulator, shell, prompt, look-and-feel tools), including look-and-feel adapters that recolor other apps from the master theme (`integrations/`); sibling repos own product integrations and plug in via `plugins/`.

## Layout

| Path | Responsibility |
|---|---|
| `wezterm.lua` | the whole WezTerm config, sectioned; loads machine/theme/plugins |
| `machine.sample.lua` → `machine.lua` (ignored) | per-machine Lua values |
| `theme.sample.lua` → `theme.lua` (ignored) | theme selector one-liner |
| `themes/*.lua`, `themes/assets/` | data-only themes + background images |
| `font.sample.lua` → `font.lua` (ignored) | font selector one-liner |
| `fonts/*.lua`; `fonts/assets/` (ignored) | data-only font registry; downloaded binaries |
| `plugins/README.md`; `plugins/*.lua` (ignored) | plugin contract; sibling-repo drop-ins |
| `shell/fish/conf.d/`, `shell/fish/functions/` | tracked fish layer, symlinked live |
| `shell/fish/machine.sample.fish` | per-machine shell values template |
| `shell/install.fish`, `shell/doctor.fish`, `shell/fonts.fish` | symlinker; report-only tool checker; font fetcher |
| `shell/oh-my-posh/theme.omp.json` | prompt theme, read from the repo path |
| `integrations/claude-code/` | master-theme → Claude Code adapter (exporter + install README) |
| `../wezterm-webview/` (sibling repo) | themed markdown/report viewer: `view <file>` + Ctrl+Alt+/ dock |
| `docs/` | verify-checklist.md — behavioral verification checklist |

## Contracts in brief

- **Theme** = pure data table (no functions, no handlers), consumed by `wezterm.lua`'s THEME APPLICATION and TAB TITLE sections and by `integrations/*/theme-export.lua` (dropping a theme field can silently break the exporter's role mapping). All chrome colors anywhere come from `theme.ui.*` — no hardcoded colors in config or plugins. A theme may also carry optional `hues` and `omp` blocks — prompt-only color washes and an oh-my-posh palette map; the exporter's `--omp` mode reads them so the prompt follows the theme, and a theme without them keeps the tracked prompt template.
- **Font** = pure data table `{ family, weight }` in `fonts/<name>.lua`, picked by the gitignored `font.lua` (default `font.sample.lua`), consumed by `wezterm.lua`'s BOOTSTRAP + FONT sections and cycled by `Alt+F` / `Alt+Shift+F` / the `font` command. Binaries live in the gitignored `fonts/assets/` (`shell/fonts.fish` fetches them); the Symbols Nerd Font Mono fallback supplies icon glyphs, so a candidate needn't be Nerd-patched.
- **Plugin** = `local M = {}; function M.apply(config, ctx) ... end; return M`. Loaded sorted, pcall-isolated, after all base sections. `ctx` = `{ wezterm, machine, theme, add_tab_overlay, add_status_cell }`. Full contract: `plugins/README.md`.
- **Per-machine** = two sample files (`machine.sample.lua`, `shell/fish/machine.sample.fish`). Drift checkpoint: adding a field to one sample may require the other — they are the one remaining duplication.

## Deployment & sync

- WezTerm: user env var `WEZTERM_CONFIG_FILE = D:\labs\wezterm\wezterm.lua` (this machine), or the 3-line shim `.wezterm.lua` documented in `setup.md` where the env var won't take.
- Fish: `fish shell/install.fish` symlinks; `00-machine.fish` is copied by hand.
- **The checkout is live.** Branch switches or rebases that momentarily remove `wezterm.lua` make the running terminal show a config error until the file returns (it auto-recovers on reload; `touch wezterm.lua` forces it). Do repo surgery from a non-WezTerm terminal if that matters.
- **Sync = `git pull`.** WezTerm auto-reloads; fish symlinks read the repo directly. The `synced-on-<hostname>` tag model is RETIRED — do not create or consult those tags. After a pull, run the drift checkpoint above plus `fish shell/doctor.fish` for new tool rows.

## Adding a theme

One new data file in `themes/<name>.lua` — copy the structure and comment style of `themes/cyberdream.lua` (fancy-bar themes also supply `tab_bar.window_frame`, see `tokyo-night.lua`). To theme the oh-my-posh prompt too, add optional `hues` and `omp` blocks to the same file (see `themes/paper.lua`); omit them and the prompt keeps the tracked `shell/oh-my-posh/theme.omp.json` template. Switch via `theme.lua`. No other file changes.

## Adding a font

Add one data file `fonts/<name>.lua` (`return { family = "...", weight = "Regular" }` — `family` must match the font's internal name; check with `fc-scan --format '%{family}\n' <file>`), add a fetch line to `shell/fonts.fish`, and run `fish shell/fonts.fish` to download the binaries into the gitignored `fonts/assets/`. Switch with `font <name>` or cycle with `Alt+F` / `Alt+Shift+F`. Nerd-Font glyphs come from the Symbols Nerd Font Mono fallback, so a plain (non-patched) build is fine. No other file changes.

## Verification

Headless load check (REPO-LOAD), must exit 0 with a font listing:

```bash
"/mnt/c/Program Files/WezTerm/wezterm.exe" --config-file 'D:\labs\wezterm\wezterm.lua' ls-fonts
```

Behavioral: walk `docs/verify-checklist.md`. Fish syntax: `fish --no-execute <file>`.
