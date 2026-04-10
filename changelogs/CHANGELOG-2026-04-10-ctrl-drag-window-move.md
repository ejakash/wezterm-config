# Ctrl+Drag to Move Window

**Date:** 2026-04-10

## Goal

Add a mouse binding to move the WezTerm window by holding Ctrl and dragging. Needed because `window_decorations = "INTEGRATED_BUTTONS|RESIZE"` removes the OS title bar, leaving no drag target for repositioning the window.

## Why not Alt+drag

Alt+drag is already used by WezTerm for column (rectangular) selection. That binding is intentionally preserved.

## Change made

Added to `config.mouse_bindings` in `.wezterm.lua`:

```lua
-- Ctrl+Drag to move the window (Alt+Drag is column select — leave that alone)
{
  event = { Drag = { streak = 1, button = "Left" } },
  mods = "CTRL",
  action = act.StartWindowDrag,
},
```

The `Drag` event fires when the mouse moves while the button is held. It does not conflict with `Ctrl+Click` (which uses the `Up` event) — clicking a link and dragging the window use separate event types.

## Things to watch out for

- Ctrl+drag also suppresses text selection for that gesture. If you need to select text while holding Ctrl, use Shift+click or copy mode (`Alt+[`) instead.
- The binding applies anywhere inside the terminal content area, not just a title bar.

## Verification

- Holding Ctrl and dragging anywhere in the window repositions it.
- Ctrl+Click on a URL still opens the link (uses `Up` event, unaffected).
- Alt+drag still performs column selection (unaffected).
