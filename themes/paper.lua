-- Paper — a warm cream light theme: fancy tab bar in a soft beige, opaque
-- background, hidden scrollbar. Tweaks land here as live use finds them.
-- Tweak log:
--   2026-06-12: background set to the warm, slightly dimmed editor tone
--   #f8efe7 the owner reads at; cursor_fg, warn_fg, active-tab bg, and
--   selection_bg (flattened over the bg) follow it.
--   2026-06-20: reworked the blue/cyan slots (both rows) so `ls` directories
--   render blue, not orange. The blue slot holds #2f6f8f — a warm teal-leaning
--   blue chosen over an earlier cold cobalt #2473b6 that read cold on the cream;
--   orange #d3582d moves into the cyan slot (ls symlinks now read orange).
--   2026-06-21: darkened bright black (brights[1]) from an earlier #a59c9c to
--   #7a6f6b (~4.3:1 on the cream) so muted text — fish autosuggestions, line
--   numbers, TUI hints — is readable. ui.muted (tab-bar separators) keeps
--   #a59c9c on purpose; separators stay subtle.
--   2026-06-22: nudged the five chromatic accents (red/green/amber/magenta/
--   orange) by <=3 per channel so each is the theme's own value rather than a
--   verbatim import; sub-perceptual. Contrast-tuned slots (bg, fg, bright-black
--   #7a6f6b, blue #2f6f8f) left exactly as-is.
return {
  colors = {
    foreground    = "#2c232e",
    background    = "#f8efe7",
    cursor_bg     = "#2c232e",
    cursor_fg     = "#f8efe7",
    cursor_border = "#2c232e",
    selection_bg  = "#e4dbd5",   -- #72696d at 15% alpha, flattened over the editor bg
    selection_fg  = "#2c232e",
    -- Light-background palette: black/white are inverted (black = light beige,
    -- white = the dark foreground), and the brights row mirrors the normal row
    -- (no separate brights are defined).
    -- Slot notes:
    --   * bright black is the muted-text gray #7a6f6b (~4.3:1 on the cream) so
    --     fish autosuggestions and TUI hints read; ui.muted keeps #a59c9c so
    --     tab-bar separators stay subtle.
    --   * the blue slot holds #2f6f8f (a warm teal-leaning blue) so `ls` dirs
    --     render blue; orange #d3582d sits in the cyan slot so ls symlinks
    --     read orange.
    ansi    = { "#d2c9c4", "#cd4872", "#228970", "#b06905", "#2f6f8f", "#6952a1", "#d3582d", "#2c232e" },
    brights = { "#7a6f6b", "#cd4872", "#228970", "#b06905", "#2f6f8f", "#6952a1", "#d3582d", "#2c232e" },
  },
  ui = {
    accent  = "#cd4872",   -- active tab (pink)
    dim     = "#92898a",   -- inactive tab
    muted   = "#a59c9c",   -- status separators
    alert   = "#d3582d",   -- key-table mode indicator (orange, distinct from accent)
    warn    = "#b06905",   -- claude-waiting tab gold
    warn_fg = "#f8efe7",   -- editor-cream on gold (inverse of the dark themes' dark-on-amber)
    warn_bg = "#f5e7d0",   -- claude-waiting pane tint — light amber, eyeball-tuned
    statusline = { shell = "#2473b6", git = "#6952a1", clock = "#2c232e" },
    scrollbar_thumb = "#d2c9c4",
  },
  -- Prompt-only specialty washes (oh-my-posh). Named for readability; literal
  -- hex because only the prompt uses them. Tuned live against the cream so the
  -- dark text on each band reads ~8-9:1. Consumed by the --omp exporter.
  hues = {
    rosy = "#e193a6", sky = "#8eb1cf", mint = "#b8d0c4",
    lavender = "#b0a0c5", peach = "#e6a389", teal = "#9ec5b5",
    gold = "#d5ac75", surface = "#ded5d0",
    garnet = "#a8201a",   -- deep error-arrow red, distinct from the rosy accent
  },
  -- oh-my-posh palette: each template key -> a name (literal #hex, a hues key,
  -- or an exporter role: accent/alert/muted/fg/...). The exporter resolves
  -- these and rewrites theme.generated.omp.json. lang_* reuse the washes and
  -- are starting points, to confirm the first time each tag appears live.
  omp = {
    text = "fg",  os_bg = "surface",  surface = "surface",
    username_bg = "rosy",  path_bg = "sky",
    git_clean = "mint",  git_dirty = "lavender",
    git_ahead = "teal",  git_behind = "peach",
    arrow_ok = "accent",  arrow_err = "garnet",  muted = "muted",
    lang_node = "mint",  lang_python = "gold",  lang_dotnet = "lavender",
    lang_go = "sky",  lang_rust = "peach",  lang_kube = "sky",
  },
  tab_bar = {
    style = "fancy",
    colors = {
      background = "#eee5de",   -- sidebar beige
      active_tab   = { bg_color = "#f8efe7", fg_color = "#cd4872" },
      inactive_tab = { bg_color = "#eee5de", fg_color = "#92898a" },
      inactive_tab_hover = { bg_color = "#ded5d0", fg_color = "#2c232e" },
    },
    -- color-only; wezterm.lua injects font/font_size (data files can't call wezterm.font).
    -- font_size 11.5 is load-bearing: 11.0 gives a wavy baseline, 12.0 overlaps the
    -- window buttons (old tab-bar-style refinement note).
    window_frame = {
      active_titlebar_bg   = "#eee5de",
      inactive_titlebar_bg = "#eee5de",
      border_left_color    = "#eee5de",
      border_right_color   = "#eee5de",
      border_top_color     = "#eee5de",
      border_bottom_color  = "#d2c9c4",
      button_fg       = "#92898a",
      button_bg       = "#eee5de",
      button_hover_fg = "#2c232e",
      button_hover_bg = "#ded5d0",
    },
  },
  background  = nil,   -- opaque editor cream, no image, default backdrop
  decorations = "INTEGRATED_BUTTONS|RESIZE",
  scrollbar   = false,
  cursor      = { style = "BlinkingBar", blink_rate = 500 },
}
