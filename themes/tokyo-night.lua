-- Tokyo Night — the original base look: fancy tab bar with integrated window
-- buttons, opaque background, visible scrollbar. Reconstructed from the old
-- tab-bar-style module docs; verified via theme round-trip in the checklist.
-- Palette from the Tokyo Night theme by Enkia (MIT, (c) 2018-present Enkia):
-- https://github.com/enkia/tokyo-night-vscode-theme
return {
  colors = {
    foreground    = "#c0caf5",
    background    = "#1a1b26",
    cursor_bg     = "#c0caf5",
    cursor_fg     = "#1a1b26",
    cursor_border = "#c0caf5",
    selection_bg  = "#33467c",
    selection_fg  = "#c0caf5",
    ansi    = { "#15161e", "#f7768e", "#9ece6a", "#e0af68", "#7aa2f7", "#bb9af7", "#7dcfff", "#a9b1d6" },
    brights = { "#414868", "#f7768e", "#9ece6a", "#e0af68", "#7aa2f7", "#bb9af7", "#7dcfff", "#c0caf5" },
  },
  ui = {
    accent  = "#7aa2f7",
    dim     = "#565f89",
    muted   = "#565f89",
    alert   = "#f7768e",
    warn    = "#e0af68",
    warn_fg = "#1a1b26",
    warn_bg = "#2a2018",
    statusline = { shell = "#7dcfff", git = "#bb9af7", clock = "#c0caf5", chip = "#292e42" },   -- chip = status-bar pill bg
    -- Dictation indicator (optional; used by the dictation-status plugin from
    -- the homemade_dictation_app repo — themes without this block fall back
    -- to generic ui colors). One color per app state; *_dim is the dark phase
    -- of that state's blink.
    dictation = {
      off              = "#565f89",  -- app not running
      idle             = "#9ece6a",  -- app alive, mic closed
      listening        = "#7dcfff",  -- mic hot, waiting for speech
      recording        = "#f7768e",  -- speech being captured (blinks)
      recording_dim    = "#7b3a47",
      transcribing     = "#e0af68",  -- whisper busy (blinks slow)
      transcribing_dim = "#705634",
    },
    split = "#3b4261",   -- pane divider
    scrollbar_thumb = "#3b4261",
  },
  tab_bar = {
    style = "fancy",
    colors = {
      background = "#1a1b26",
      active_tab   = { bg_color = "#1a1b26", fg_color = "#c0caf5" },
      inactive_tab = { bg_color = "#16171f", fg_color = "#565f89" },
      inactive_tab_hover = { bg_color = "#292e42", fg_color = "#c0caf5" },
    },
    -- color-only; wezterm.lua injects font/font_size (data files can't call wezterm.font).
    -- font_size 11.5 is load-bearing: 11.0 gives a wavy baseline, 12.0 overlaps the
    -- window buttons (old tab-bar-style refinement note).
    window_frame = {
      active_titlebar_bg   = "#1a1b26",
      inactive_titlebar_bg = "#16171f",
      border_left_color    = "#1a1b26",
      border_right_color   = "#1a1b26",
      border_top_color     = "#1a1b26",
      border_bottom_color  = "#3b4261",
      button_fg       = "#565f89",
      button_bg       = "#1a1b26",
      button_hover_fg = "#c0caf5",
      button_hover_bg = "#292e42",
    },
  },
  background = nil,   -- opaque scheme background, no image, default backdrop
  decorations = "INTEGRATED_BUTTONS|RESIZE",
  scrollbar   = true,
  cursor      = { style = "BlinkingBar", blink_rate = 500 },
}
