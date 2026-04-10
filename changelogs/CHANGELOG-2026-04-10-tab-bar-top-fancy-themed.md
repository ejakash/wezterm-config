# Tab Bar: Moved to Top, Fancy Style, Fully Tokyo Night Themed

**Date:** 2026-04-10

## Goal

Move the tab bar from the bottom to the top of the window, make it always visible, switch to the fancy tab bar style to get per-tab close buttons and integrated window controls, and theme everything to match Tokyo Night with no visible seams.

## Problem with the original setup

The original config used `window_decorations = "RESIZE"` with a retro tab bar at the bottom. On Windows 11, the DWM renders caption buttons (minimize/maximize/close) as non-client elements at the top of the window frame, but WezTerm's GPU-rendered content covers the hit-test area — clicks pass through. The buttons were visible but non-functional.

Switching to `INTEGRATED_BUTTONS|RESIZE` tells WezTerm to render its own clickable window control buttons inside the tab bar. With the tab bar at the top, these align naturally where window controls are expected.

The retro tab bar (`use_fancy_tab_bar = false`) does not support independently sized per-tab close buttons or per-tab X close actions. The fancy bar does.

## Changes made

### `window_decorations`

```lua
-- Before
config.window_decorations = "RESIZE"

-- After
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
```

`INTEGRATED_BUTTONS` renders clickable min/max/close buttons inside the tab bar. `RESIZE` keeps OS resize handles on the window edges.

### Tab bar settings

```lua
-- Before
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true

-- After
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = false
```

- `use_fancy_tab_bar = true`: enables per-tab close buttons and INTEGRATED_BUTTONS support
- `tab_bar_at_bottom = false`: moves bar to top where window controls are expected
- `hide_tab_bar_if_only_one_tab = false`: keeps bar always visible for status info and window controls

### `window_frame` (new block)

The fancy tab bar exposes a `window_frame` config. Without it, WezTerm uses its default gray, which clashes visibly with the dark Tokyo Night background.

```lua
config.window_frame = {
  font = wezterm.font("JetBrains Mono", { weight = "Medium" }),
  font_size = 11.0,
  -- Match the tab bar background exactly — eliminates the "two layers" seam
  active_titlebar_bg   = "#1a1b26",
  inactive_titlebar_bg = "#16171f",
  -- Invisible borders so the frame blends in
  border_left_color   = "#1a1b26",
  border_right_color  = "#1a1b26",
  border_top_color    = "#1a1b26",
  border_bottom_color = "#3b4261",   -- subtle separator between bar and terminal
  -- Integrated min/max/close buttons themed to match
  button_fg         = "#565f89",
  button_bg         = "#1a1b26",
  button_hover_fg   = "#c0caf5",
  button_hover_bg   = "#292e42",
}
```

Key fields:
- `active_titlebar_bg` / `inactive_titlebar_bg`: the overall frame background. Must match `colors.tab_bar.background` (`#1a1b26`) or a seam appears between tab items and the frame.
- `border_bottom_color = "#3b4261"`: a thin separator between the tab bar and terminal content.
- `button_*`: the min/max/close button colors. Set to match the muted Tokyo Night palette.

## Things to watch out for

- `INTEGRATED_BUTTONS` only renders clickable buttons in the fancy bar (`use_fancy_tab_bar = true`). With the retro bar it has no effect.
- On Windows, DWM may still render faint caption button outlines at the top. With the tab bar at the top, WezTerm's content overlaps this area, visually hiding them.
- `inactive_titlebar_bg` should be slightly darker than `active_titlebar_bg` so there's a subtle cue when the window loses focus.
- The `border_bottom_color` creates a 1px-ish separator. Setting it to `#1a1b26` makes it invisible if you prefer no separator.

## Verification

- Tab bar appears at the top with Tokyo Night dark background, no gray seam.
- Min/max/close buttons in the top-right corner are clickable.
- Per-tab X close buttons visible on each tab.
- Window is resizable by dragging edges/corners.
- Tab bar visible with a single tab open.
- Right-status elements (shell type, git branch, datetime) appear in the top-right of the bar.
- Window unfocused: bar darkens slightly to `#16171f`.
