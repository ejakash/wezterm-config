-- Cyberdream — neon dark theme. Transparent retro tab bar, procedural background
-- (soft neon glows on near-black) + Acrylic blur, no scrollbar. Data only: no
-- functions, no handlers (see spec).
-- Palette from cyberdream.nvim by Scott McKendry (MIT, (c) 2023 Scott McKendry):
-- https://github.com/scottmckendry/cyberdream.nvim
return {
  colors = {
    foreground    = "#ffffff",
    background    = "#16181a",
    cursor_bg     = "#ffffff",
    cursor_fg     = "#16181a",
    cursor_border = "#ffffff",
    selection_bg  = "#3c4048",
    selection_fg  = "#ffffff",
    ansi    = { "#16181a", "#ff6e5e", "#5eff6e", "#f1ff5e", "#5ea1ff", "#bd5eff", "#5ef1ff", "#ffffff" },
    brights = { "#3c4048", "#ff6e5e", "#00ff77", "#fff66b", "#5ea1ff", "#bd5eff", "#5ef1ff", "#ffffff" },
  },
  ui = {
    accent  = "#5ef1ff",   -- active tab
    dim     = "#5ea1ff",   -- inactive tab
    muted   = "#565f89",   -- status separators
    alert   = "#f7768e",   -- key-table mode indicator
    warn    = "#e0af68",   -- claude-waiting tab amber
    warn_fg = "#1a1b26",   -- text on warn
    warn_bg = "#2a2018",   -- claude-waiting pane bg tint
    statusline = { shell = "#7dcfff", git = "#bb9af7", clock = "#c0caf5", chip = "#3c4048" },   -- chip = status-bar pill bg
    -- Dictation indicator (optional; used by the dictation-status plugin from
    -- the homemade_dictation_app repo — themes without this block fall back
    -- to generic ui colors). One color per app state; *_dim is the dark phase
    -- of that state's blink.
    dictation = {
      off              = "#565f89",  -- app not running
      idle             = "#5eff6e",  -- app alive, mic closed
      listening        = "#5ef1ff",  -- mic hot, waiting for speech
      recording        = "#ff6e5e",  -- speech being captured (blinks)
      recording_dim    = "#80372f",
      transcribing     = "#f1ff5e",  -- whisper busy (blinks slow)
      transcribing_dim = "#78802f",
    },
    split = "#3c4048",   -- pane divider
    scrollbar_thumb = "#3b4261",
  },
  tab_bar = {
    style = "retro",
    -- passed through verbatim as config.colors.tab_bar; rgba(0,0,0,0) = transparent
    -- (deliberate: transparency is expressed in the colors, not a separate flag)
    colors = {
      background = "rgba(0,0,0,0)",
      active_tab   = { bg_color = "rgba(0,0,0,0)", fg_color = "#5ef1ff", intensity = "Bold" },
      inactive_tab = { bg_color = "rgba(0,0,0,0)", fg_color = "#5ea1ff" },
      inactive_tab_hover = { bg_color = "rgba(60,64,72,0.4)", fg_color = "#ffffff" },
    },
    window_frame = nil,   -- retro bar doesn't use it
  },
  background = { image = "cyberdream-bg.png", backdrop = "Acrylic", opacity = 1.0 },  -- image: relative to themes/assets/
  decorations = "RESIZE",
  scrollbar   = false,
  cursor      = { style = "BlinkingBar", blink_rate = 500 },
}
