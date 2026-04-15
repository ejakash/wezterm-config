# Tab bar font size fix — wavy baseline on tab titles

## What

Tab title text had a subtle wavy/uneven baseline — letters sitting at slightly different heights, making the text look curved.

## Why

WezTerm's fancy tab bar uses a different text rasterization path than the terminal pane. At `font_size = 11.0`, JetBrains Mono's glyph metrics cause inconsistent vertical alignment across characters. Whole-number sizes that align cleanly to pixel boundaries eliminate the issue.

## Change

In `config.window_frame`:

```lua
-- before
font_size = 11.0,

-- after
font_size = 11.5,
```

Note: 11.0 causes wavy baseline. 12.0 fixes waviness but tab bar becomes too tall, overlapping the window control buttons. 11.5 is the sweet spot — clean baseline, no overlap.

## Verification

Switched to 11.5 — tab title baseline uniform, no overlap with window controls. Confirmed on WSL2 / Windows with WezTerm fancy tab bar.
