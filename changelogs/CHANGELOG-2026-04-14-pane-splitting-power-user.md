# Pane Splitting Power-User Setup

**Date:** 2026-04-14  
**Classification:** [setup]

## Goal

Set up ergonomic pane splitting with arrow-key navigation, a modal resize mode, and a status bar indicator showing when a key table mode is active.

## Changes

### 1. Split Keys

`Alt+/` = split right (side by side), `Alt+.` = split down (stacked). Uses `SplitHorizontal`/`SplitVertical` with `CurrentPaneDomain` — simple and reliable. The CWD-aware `action_callback` approach was tried but caused issues; reverted to direct actions.

Note: `Alt+.` intercepts bash readline's `insert-last-argument` shortcut. If that's needed, rebind to `Alt+,` or similar.

### 2. Pane Navigation (Alt+arrows)

`Alt+arrows` for all four directions. Previous `Alt+Left/Right` tab-switching bindings removed — tabs now navigate via `Ctrl+Tab`/`Ctrl+Shift+Tab`/`Alt+1-5` only.

- `Alt+H` → focus pane to the left
- `Alt+J` → focus pane below
- `Alt+K` → focus pane above
- `Alt+L` → focus pane to the right

### 3. Modal Resize Mode (Alt+R)

Added a `resize_pane` key table activated with `Alt+R`. While in resize mode:
- `h/j/k/l` or arrow keys → adjust pane size by 3 cells
- `Escape`, `q`, or `Enter` → exit resize mode

The status bar shows `[RESIZE PANE]` in red while this mode is active.

The existing `Alt+Shift+arrows` one-shot resize bindings are kept as a quick alternative.

### 4. Rotate Panes (Alt+O)

Added `Alt+O` → `RotatePanes("Clockwise")`. Cycles panes clockwise within the current tab. Useful when you split and want to swap which pane is on which side without closing and re-splitting.

### 5. Status Bar Mode Indicator

The `update-status` handler now checks `window:active_key_table()` at the start of each tick. If a key table is active, it prepends `[MODE NAME]` in red (`#f7768e`) before the shell icon/git branch/time section.

## Full Keybinding Reference

### Splitting
| Key | Action |
|-----|--------|
| `Alt+\` | Split right (side by side), inherits CWD |
| `Alt+-` | Split down (stacked), inherits CWD |

### Navigation
| Key | Action |
|-----|--------|
| `Alt+H` | Focus pane left |
| `Alt+J` | Focus pane below |
| `Alt+K` | Focus pane above |
| `Alt+L` | Focus pane right |
| `Ctrl+Alt+arrows` | Pane navigation (arrow variant) |
| `Alt+Left/Right` | Tab navigation (unchanged) |
| `Alt+Up/Down` | Pane navigation up/down (unchanged) |

### Resizing
| Key | Action |
|-----|--------|
| `Alt+R` | Enter resize mode (then tap keys, Escape exits) |
| `Alt+Shift+arrows` | One-shot resize by 3 cells |

### Other
| Key | Action |
|-----|--------|
| `Alt+Z` | Toggle pane zoom (existing) |
| `Alt+O` | Rotate panes clockwise |
| `Ctrl+Shift+W` | Close current pane (existing) |

## Files Modified

- `/mnt/c/Users/AkashJohny/.wezterm.lua`

## Verification

1. Open WezTerm — confirm it reloads without errors.
2. `cd` into a project directory, then `Alt+\` — new pane should open in the same directory.
3. With two panes open, press `Alt+H`/`Alt+L` — focus should jump between panes.
4. Press `Alt+R` — status bar should show `[RESIZE PANE]`. Press `h`/`j`/`k`/`l` — pane should resize. Press `Escape` — mode exits, indicator disappears.
5. Press `Alt+O` with multiple panes — panes should cycle positions.
