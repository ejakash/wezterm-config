# Terminal chrome — pill status segments and a themed pane divider

## Goal

Restyle the WezTerm status bar so each segment is a rounded "pill" card, and give
pane dividers a themed warm hairline. Drive both from theme data. Add a reusable
pill renderer to the plugin context so plugins render status cells that match the
base bar.

## Decisions

### 1. Status segments as pills

Each base segment — font, shell/OS, git, clock — renders as a rounded pill: a
half-circle left cap, a filled body, a half-circle right cap. The caps are the
Symbols Nerd Font glyphs U+E0B6 and U+E0B4, drawn in the chip color over the bar
background so the rounded ends read as part of the body. The body keeps the
segment's existing text color on a shared chip background. The old U+2502
separators are removed. The pills do the separating.

### 2. Theme tokens

Two new data-only tokens, added to every theme:

- `theme.ui.statusline.chip` — the pill background. paper-wove uses `#f0e3da`.
- `theme.ui.split` — the pane divider color. paper-wove uses `#cdbfa3`.

`wezterm.lua` degrades safely when a token is missing. An absent `split` leaves
WezTerm's default divider. An absent `chip` falls back to the background, so a
pill becomes plain text rather than breaking the bar.

### 3. A shared pill renderer on `ctx`

`wezterm.lua` defines `render_segment` and exposes it on the plugin context as
`ctx.render_segment`. It returns a `FormatItem` list for one pill. A status-cell
provider returns `ctx.render_segment{...}` and matches the base bar with no extra code.
This is the consistency primitive for current and future plugins.

```
ctx.render_segment{ text = "LISTEN", fg = theme.ui.accent, chip = <optional>, bold = <optional> }
  -> FormatItem[]
```

Defaults: `chip` is `theme.ui.statusline.chip`; the bar color is the tab-bar
background; `fg` is the foreground.

### 4. Pane separation

Light themes drop the inactive-pane dim. Every pane is then the same brightness
and the divider reads identically no matter which pane is active. The themed
hairline carries the separation. Dark themes keep their existing dim, where it
reads well. The active pane is shown by the cursor.

### 5. Plugin contract

`plugins/README.md` documents `ctx.render_segment`. `CLAUDE.md` and `AGENTS.md` update
the `ctx` shape. The dictation plugin adopts `ctx.render_segment` for its LISTEN cell,
which restores its real leftmost position and live mode-switching while keeping
the native look. Until it adopts the helper, its cell renders in its own style.

## Verification

- Headless REPO-LOAD must exit 0:
  `wezterm.exe --config-file 'D:\labs\wezterm\wezterm.lua' ls-fonts`
- Visual: the status bar pills and a four-pane divider, checked after a clean
  WezTerm restart.

## Open follow-up

The inactive-pane "diagonal" tone the owner saw is a transient of the flaky
WSL-side config reload, not a baked-in effect. Confirm it is gone after a clean
restart.
