-- Paper-wove — the wove-textured sibling of `paper`. Same warm cream light
-- palette (inherited verbatim from paper.lua — see its tweak log for the
-- per-slot history); two deltas only:
--   1. background is a generated wove paper texture instead of flat cream, and
--   2. the fancy tab bar / window frame is recolored from paper's sidebar-beige
--      #eee5de to the cream #f8efe7, so the bar matches the field instead of
--      reading as a separate strip (the beige/cream mismatch the owner flagged).
--
-- Texture (themes/assets/paper-wove-bg.png — original/generated, no downloaded
-- asset): neutral multi-octave (FBM) grain weighted to the fine end (wove =
-- fine, uniform tooth; no low-frequency mottle clouds, calibrated against
-- public-domain wove references), added as a ZERO-MEAN signed layer over
-- #f8efe7. Mean luminance therefore stays exactly on the cream, so the contrast
-- baseline is unmoved (muted #7a6f6b verified ~4.6:1) and there is no warm/yellow
-- drift. 2560x1440, 256-colour palette (~1.2 MB). Regenerate with the scratchpad
-- gen-wove.sh (seeds 7/11/19) if the asset is ever lost.
-- Tweak log:
--   2026-06-22: cloned from paper; added the wove texture bg + cream-matched
--   fancy bar. Bar carries a whisper separator (#ece2da) under it; set
--   border_bottom_color to #f8efe7 for a fully seamless bar.
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
    statusline = { shell = "#2473b6", git = "#6952a1", clock = "#2c232e", chip = "#f0e3da" },   -- chip = status-bar pill bg
    split = "#cdbfa3",   -- pane divider hairline (warm taupe)
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
      background = "#f8efe7",   -- cream, matches the terminal background (paper used sidebar beige #eee5de)
      active_tab   = { bg_color = "#f8efe7", fg_color = "#cd4872" },
      inactive_tab = { bg_color = "#f8efe7", fg_color = "#92898a" },
      inactive_tab_hover = { bg_color = "#ece2da", fg_color = "#2c232e" },
    },
    -- color-only; wezterm.lua injects font/font_size (data files can't call wezterm.font).
    -- font_size 11.5 is load-bearing: 11.0 gives a wavy baseline, 12.0 overlaps the
    -- window buttons (old tab-bar-style refinement note).
    window_frame = {
      active_titlebar_bg   = "#f8efe7",
      inactive_titlebar_bg = "#f8efe7",
      border_left_color    = "#f8efe7",
      border_right_color   = "#f8efe7",
      border_top_color     = "#f8efe7",
      border_bottom_color  = "#ece2da",   -- whisper separator under the bar (set to #f8efe7 for seamless)
      button_fg       = "#92898a",
      button_bg       = "#f8efe7",
      button_hover_fg = "#2c232e",
      button_hover_bg = "#ece2da",
    },
  },
  background  = { image = "paper-wove-bg.png", opacity = 1.0 },   -- generated wove texture; opaque
  decorations = "INTEGRATED_BUTTONS|RESIZE",
  scrollbar   = false,
  cursor      = { style = "BlinkingBar", blink_rate = 500 },
}
