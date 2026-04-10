# Vertical Scrollbar

**Date:** 2026-04-04
**Status:** [setup]

## Goal

Add a visible vertical scrollbar so scrollback is easier to navigate than relying on the mouse wheel alone.

## Changes

In `.wezterm.lua`:

- Set `config.enable_scroll_bar = true` (was `false`).
- Added `config.min_scroll_bar_height = "1cell"` for a larger drag target.
- Added `scrollbar_thumb = "#3b4261"` inside `config.colors` to match the Tokyo Night palette.

## Watch-outs

- WezTerm renders the scrollbar inside the right padding area, so the existing `right = 12` padding remains in use.
- The scrollbar only appears when there is scrollback content above the visible area.
