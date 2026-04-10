# Tab Navigation Keybinding Remap

**Date:** 2026-03-30
**Status:** [setup]

## Goal

Use `Alt+Left` and `Alt+Right` to move between WezTerm tabs instead of panes. Keep pane navigation available on different keybindings.

## Changes

In `.wezterm.lua`, updated the keybindings section:

- `Alt+Left` → `ActivateTabRelative(-1)` (was pane left)
- `Alt+Right` → `ActivateTabRelative(1)` (was pane right)
- `Ctrl+Alt+Left` → `ActivatePaneDirection("Left")` (new binding for pane focus)
- `Ctrl+Alt+Right` → `ActivatePaneDirection("Right")` (new binding for pane focus)
- `Alt+Up` and `Alt+Down` remain pane-focus shortcuts for vertical movement.

## Watch-outs

- `Ctrl+Tab` and `Ctrl+Shift+Tab` remain available as alternate tab navigation shortcuts.
- The setup guide, verification checklist, and keybinding cheat sheet all needed updating to match.
