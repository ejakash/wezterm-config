-- wezterm.lua — the whole WezTerm config. Sections below; per-machine values in
-- machine.lua (copy machine.sample.lua), look-and-feel in themes/<name>.lua
-- (selected by theme.lua), cross-cutting drop-ins in plugins/*.lua.
-- Deployed by pointing the WEZTERM_CONFIG_FILE env var at this file (see setup.md).
local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- ==========================================================================
--  BOOTSTRAP — repo paths, machine values, theme, plugin context
-- ==========================================================================
-- Directory containing this file, Windows-style (we run on the Windows side).
-- __TERMINAL_REPO_DIR is only set by the fallback shim (see setup.md): if the
-- WEZTERM_CONFIG_FILE env var can't be used, a 3-line C:\Users\<u>\.wezterm.lua
-- sets it and dofile()s this file, so config_file points at the shim instead.
local REPO_DIR = _G.__TERMINAL_REPO_DIR or wezterm.config_file:gsub("[/\\][^/\\]+$", "")
local function repo_path(rel) return REPO_DIR .. "\\" .. rel:gsub("/", "\\") end
-- wezterm-webview lives as a SIBLING of this repo (../wezterm-webview), not inside
-- it — WezTerm's Lua won't follow a junction into the tree, so reference the real path.
local WEBVIEW_DIR = REPO_DIR:gsub("[/\\][^/\\]+$", "") .. "\\wezterm-webview"

local function load_if_exists(path)
  local f = io.open(path, "r")
  if not f then return nil end
  f:close()
  return dofile(path)
end

local machine = load_if_exists(repo_path("machine.lua"))
if not machine then
  error("machine.lua not found (or returned nothing) in " .. REPO_DIR ..
        " — copy machine.sample.lua to machine.lua and edit (see setup.md)")
end

local theme_name = load_if_exists(repo_path("theme.lua"))
                or dofile(repo_path("theme.sample.lua"))
local theme = load_if_exists(repo_path("themes/" .. theme_name .. ".lua"))
if not theme then
  error("theme '" .. tostring(theme_name) .. "' not found or empty — " ..
        "check theme.lua against the files in themes/")
end

-- Selected font: font.lua (gitignored) or the tracked font.sample.lua default,
-- naming a tracked registry file fonts/<name>.lua ({ family, weight }). Cycle
-- with Alt+F / Alt+Shift+F or the `font` shell command. Binaries live in the
-- gitignored fonts/assets/ — run shell/fonts.fish to (re)populate them.
local font_name = load_if_exists(repo_path("font.lua"))
              or dofile(repo_path("font.sample.lua"))
local font_def = load_if_exists(repo_path("fonts/" .. font_name .. ".lua"))
if not font_def then
  error("font '" .. tostring(font_name) .. "' not found or empty — " ..
        "check font.lua against the files in fonts/")
end

-- markdown-viewer (../wezterm-webview): a chromeless browser pane docked beside
-- WezTerm. Driven by the Ctrl+Alt+/ keybind (see config.keys) and by the `mdview`
-- user-var that `view <file>` emits (agent/CLI trigger).
-- ../wezterm-webview is an OPTIONAL sibling. If it isn't cloned, degrade the
-- dock to no-ops so the rest of the config still loads (same load_if_exists
-- pattern as machine/theme/font above).
local mdview = load_if_exists(WEBVIEW_DIR .. "\\dock.lua")
local have_webview = mdview ~= nil
mdview = mdview or { on_user_var = function() end, toggle = function() end }
wezterm.on("user-var-changed", function(win, pane, name, val)
  mdview.on_user_var(win, pane, name, val)
end)

-- dofile'd files are NOT auto-watched (only the main config and require'd
-- files are) — register them so editing machine/theme files hot-reloads.
for _, watched in ipairs({ "wezterm.lua", "machine.lua", "theme.lua", "theme.sample.lua",
                           "themes/" .. theme_name .. ".lua", "font.lua", "font.sample.lua",
                           "fonts/" .. font_name .. ".lua" }) do
  wezterm.add_to_config_reload_watch_list(repo_path(watched))
end
if have_webview then
  wezterm.add_to_config_reload_watch_list(WEBVIEW_DIR .. "\\dock.lua")  -- sibling project
end

-- Plugin context + tab-title overlay / status-cell chains (see plugins/README.md).
local tab_overlays = {}
local status_cell_providers = {}
local ctx = {
  wezterm = wezterm,
  machine = machine,
  theme = theme,
  add_tab_overlay = function(fn) table.insert(tab_overlays, fn) end,
  add_status_cell = function(fn) table.insert(status_cell_providers, fn) end,
}

-- ==========================================================================
--  THEME APPLICATION — every theme key is consumed here or in the tab bar
-- ==========================================================================
config.color_schemes = { [theme_name] = theme.colors }
config.color_scheme = theme_name

config.window_decorations = theme.decorations
config.window_background_opacity = theme.background and theme.background.opacity or 1.0
if theme.background and theme.background.image then
  config.window_background_image = repo_path("themes/assets/" .. theme.background.image)
end
config.win32_system_backdrop = theme.background and theme.background.backdrop or "Auto"

config.enable_scroll_bar = theme.scrollbar
config.default_cursor_style = theme.cursor.style
config.cursor_blink_rate = theme.cursor.blink_rate

config.use_fancy_tab_bar = (theme.tab_bar.style == "fancy")
config.colors = { scrollbar_thumb = theme.ui.scrollbar_thumb, tab_bar = theme.tab_bar.colors }
if theme.tab_bar.window_frame then
  local wf = {}
  for k, v in pairs(theme.tab_bar.window_frame) do wf[k] = v end
  -- Themes are data-only and can't call wezterm.font; inject font here.
  wf.font = wezterm.font("JetBrains Mono", { weight = "Medium" })
  wf.font_size = 11.5  -- 11.0 = wavy baseline, 12.0 = overlaps window buttons
  config.window_frame = wf
end

-- ==========================================================================
--  TAB TITLE — single handler; plugins register overlays via ctx.add_tab_overlay
-- ==========================================================================
wezterm.on("format-tab-title", function(tab, tabs, panes)
  local title = tab.active_pane.title
  if #title > 72 then title = wezterm.truncate_right(title, 70) .. ".." end
  local label = string.format("  %d: %s  ", tab.tab_index + 1, title)

  for _, overlay in ipairs(tab_overlays) do
    local ok, result = pcall(overlay, tab, label, ctx)
    if not ok then
      wezterm.log_error("tab overlay failed: " .. tostring(result))
    elseif result then
      return result
    end
  end

  if tab.is_active then
    return {
      { Attribute = { Intensity = "Bold" } },
      { Foreground = { Color = theme.ui.accent } },
      { Text = label },
    }
  end
  return { { Foreground = { Color = theme.ui.dim } }, { Text = label } }
end)

-- ==========================================================================
--  DEFAULT SHELL — WSL (distro + start dir from machine.lua)
-- ==========================================================================
config.default_domain = "WSL:" .. machine.wsl_distro

-- config.default_cwd does not work reliably for WSL domains. Use wsl_domains
-- to set the starting directory at the domain level instead.
-- default_cwd comes from machine.lua.
config.wsl_domains = {
  {
    name = "WSL:" .. machine.wsl_distro,
    distribution = machine.wsl_distro,
    default_cwd = machine.default_cwd,
  },
}

-- ==========================================================================
--  FONT — family from the selected fonts/<name>.lua (font.lua selector; Alt+F
--  to cycle). The Symbols Nerd Font Mono fallback stays so every candidate gets
--  icon glyphs even without its own patched build.
-- ==========================================================================
config.font_dirs = { repo_path("fonts/assets") }
config.font = wezterm.font_with_fallback({
  { family = font_def.family, weight = font_def.weight or "Regular", harfbuzz_features = { "calt=1", "clig=1", "liga=1" } },
  { family = "Symbols Nerd Font Mono" },
  "Noto Color Emoji",
})
config.font_size = 11.5
config.line_height = 1.15
config.cell_width = 0.9

-- Rendering, tuned for the owner's display: grayscale AA
-- (render_target = Normal) because the LG C3 OLED's WRGB subpixels fringe under
-- subpixel AA; Light load_target = vertical-only hinting (crisp, shape-true at
-- 4K); pairs with front_end = OpenGL below (avoids the WebGpu gamma/thinness
-- bug, wezterm #3032).
config.freetype_load_target = "Light"
config.freetype_render_target = "Normal"
-- ==========================================================================
--  WINDOW — geometry & padding
-- ==========================================================================
config.window_padding = { left = 12, right = 12, top = 8, bottom = 4 }
config.initial_cols = 140
config.initial_rows = 38
config.window_close_confirmation = "NeverPrompt"

-- ==========================================================================
--  TAB BAR — behavior (position, visibility, width)
-- ==========================================================================
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = false   -- always visible for status info
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 80

-- ==========================================================================
--  CURSOR
-- ==========================================================================
-- Cursor style + blink rate are theme-owned (see THEME APPLICATION); easing is behavior.
config.cursor_blink_ease_in = "EaseIn"
config.cursor_blink_ease_out = "EaseOut"
config.force_reverse_video_cursor = false

-- ==========================================================================
--  SCROLLBACK & PERFORMANCE
-- ==========================================================================
config.scrollback_lines = 10000
config.min_scroll_bar_height = "1cell"
config.max_fps = 120
config.animation_fps = 120
config.front_end = "OpenGL"                   -- FONT TRIAL: OpenGL avoids WebGpu gamma/thinness bug on Windows (was "WebGpu")

-- ==========================================================================
--  BELL — Visual only, no sound
-- ==========================================================================
config.audible_bell = "Disabled"
config.visual_bell = {
  fade_in_duration_ms = 75,
  fade_out_duration_ms = 100,
  target = "CursorColor",
}

-- ==========================================================================
--  KEYBINDINGS — Sensible defaults + split pane power-user shortcuts
-- ==========================================================================

-- Pick a safe CWD for new panes. Tolerates all three shapes WezTerm has returned
-- over the years (nil, plain string URL, {file_path=..., host=...}) and rejects
-- Windows-style paths that would fail chdir in the WSL domain.
local FALLBACK_CWD = machine.default_cwd
local function resolve_cwd(pane)
  local ok, cwd_url = pcall(function() return pane:get_current_working_dir() end)
  if not ok or cwd_url == nil then return FALLBACK_CWD end
  local path
  if type(cwd_url) == "string" then
    path = cwd_url:match("^file://[^/]*(/.*)$") or cwd_url
  elseif type(cwd_url) == "userdata" or type(cwd_url) == "table" then
    path = cwd_url.file_path
  end
  if type(path) ~= "string" or path == "" then return FALLBACK_CWD end
  -- Reject Windows drive paths (C:\..., \\server\...) — WSL chdir will fail.
  if path:match("^%a:[/\\]") or path:match("^\\\\") then return FALLBACK_CWD end
  return path
end

-- Match key assignments by PHYSICAL key position + actual modifiers, not the resolved
-- character. This is the robust fix for the Caps Lock footgun: with the default "Mapped"
-- preference, a binding like { key = "w", mods = "CTRL|SHIFT" } folds Shift into a capital
-- "W" and matches Ctrl + capital-W *however the capital was produced* — so Caps Lock + Ctrl+W
-- (no Shift modifier) would trigger close-pane/close-tab. "Physical" requires the real Shift
-- modifier, which Caps Lock never sets, so plain Ctrl+W always falls through to the shell's
-- word-delete. Punctuation keys with no physical name (/, =, -, [) stay mapped automatically.
config.key_map_preference = "Physical"

-- Cycle font.lua to the next/prev registry entry (fonts/*.lua, sorted) and force
-- a reload — sibling of the Alt+T theme cycle.
local function cycle_font(win, pane, dir)
  local names = {}
  for _, path in ipairs(wezterm.glob(repo_path("fonts/*.lua"))) do
    table.insert(names, (path:match("([^/\\]+)%.lua$")))
  end
  table.sort(names)
  if #names == 0 then return end
  local cur = load_if_exists(repo_path("font.lua")) or font_name
  local idx = 1
  for i, n in ipairs(names) do if n == cur then idx = i; break end end
  local nxt = names[((idx - 1 + dir) % #names) + 1]
  local f, err = io.open(repo_path("font.lua"), "w")
  if not f then wezterm.log_error("font cycle: cannot write font.lua: " .. tostring(err)); return end
  f:write('return "' .. nxt .. '"\n')
  f:close()
  win:perform_action(act.ReloadConfiguration, pane)
end

config.keys = {
  -- Pane splitting
  -- Alt+/  = split right (side by side), inherits CWD via OSC 7
  -- Alt+.  = split down (stacked), inherits CWD via OSC 7
  -- resolve_cwd is defensive: older WezTerm builds return a plain string URL instead of a
  -- {file_path=...} object, and Windows-style paths (C:\...) from a stale CWD would fail WSL chdir.
  { key = "/", mods = "ALT", action = wezterm.action_callback(function(win, pane)
    win:perform_action(act.SplitHorizontal({ domain = "CurrentPaneDomain", cwd = resolve_cwd(pane) }), pane)
  end) },
  { key = ".", mods = "ALT", action = wezterm.action_callback(function(win, pane)
    win:perform_action(act.SplitVertical({ domain = "CurrentPaneDomain", cwd = resolve_cwd(pane) }), pane)
  end) },
  -- Ctrl+Alt+/ = open/close the markdown-viewer browser pane on the right (same
  -- `/` = "split right" family; phys:Slash so AltGr layouts can't intercept it).
  { key = "phys:Slash", mods = "CTRL|ALT", action = wezterm.action_callback(function(win, pane)
    mdview.toggle(win, pane)
  end) },

  -- Pane navigation — Alt+arrows for all four directions
  { key = "LeftArrow",  mods = "ALT", action = act.ActivatePaneDirection("Left") },
  { key = "RightArrow", mods = "ALT", action = act.ActivatePaneDirection("Right") },
  { key = "UpArrow",    mods = "ALT", action = act.ActivatePaneDirection("Up") },
  { key = "DownArrow",  mods = "ALT", action = act.ActivatePaneDirection("Down") },
  -- Tab navigation — Ctrl+Tab / Ctrl+Shift+Tab (see below) and Alt+1-5

  -- Pane resize:
  --   Alt+R            → enter resize mode (tap h/j/k/l or arrows freely, Escape exits)
  --   Alt+Shift+arrows → one-shot resize without entering a mode
  { key = "r", mods = "ALT", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },
  { key = "LeftArrow",  mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Left",  3 }) },
  { key = "RightArrow", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Right", 3 }) },
  { key = "UpArrow",    mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Up",    3 }) },
  { key = "DownArrow",  mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Down",  3 }) },

  -- Scrollback: Shift+Up/Down line-by-line, Ctrl+Shift+Up/Down quarter-page
  { key = "UpArrow",    mods = "SHIFT",      action = act.ScrollByLine(-1) },
  { key = "DownArrow",  mods = "SHIFT",      action = act.ScrollByLine(1) },
  { key = "UpArrow",    mods = "CTRL|SHIFT", action = act.ScrollByPage(-0.25) },
  { key = "DownArrow",  mods = "CTRL|SHIFT", action = act.ScrollByPage(0.25) },

  -- Rotate panes clockwise within the current tab (Alt+O)
  { key = "o", mods = "ALT", action = act.RotatePanes("Clockwise") },

  -- Close pane (Ctrl+Shift+W). Relies on key_map_preference = "Physical" (set above) so this
  -- matches the physical W key plus a *real* Shift modifier. Without it WezTerm folds Shift into
  -- an uppercase "W" and stores the binding as bare Ctrl+W, so Caps Lock + Ctrl+W (a capital W
  -- with NO Shift modifier) also matched and silently killed the pane/app.
  { key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = false }) },

  -- New tab
  { key = "t", mods = "CTRL|SHIFT", action = act.SpawnCommandInNewTab({
    domain = { DomainName = "WSL:" .. machine.wsl_distro },
    cwd = machine.default_cwd,
  }) },

  -- Tab navigation (Ctrl+Tab / Ctrl+Shift+Tab)
  { key = "Tab", mods = "CTRL",       action = act.ActivateTabRelative(1) },
  { key = "Tab", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },

  -- Quick tab switch (Alt + 1-5)
  { key = "1", mods = "ALT", action = act.ActivateTab(0) },
  { key = "2", mods = "ALT", action = act.ActivateTab(1) },
  { key = "3", mods = "ALT", action = act.ActivateTab(2) },
  { key = "4", mods = "ALT", action = act.ActivateTab(3) },
  { key = "5", mods = "ALT", action = act.ActivateTab(4) },

  -- Zoom pane toggle (Alt+Z)
  { key = "z", mods = "ALT", action = act.TogglePaneZoomState },

  -- Theme cycling (Alt+T): rewrite the gitignored theme.lua selector to the
  -- next themes/*.lua (sorted) and force a reload — the whole theme (palette,
  -- tab bar, background, scrollbar) hot-swaps. Reload is forced rather than
  -- left to the watcher: a watched path that didn't exist yet (first cycle
  -- creates theme.lua) doesn't reliably fire it.
  { key = "t", mods = "ALT", action = wezterm.action_callback(function(win, pane)
    local names = {}
    for _, path in ipairs(wezterm.glob(repo_path("themes/*.lua"))) do
      table.insert(names, (path:match("([^/\\]+)%.lua$")))
    end
    table.sort(names)
    if #names == 0 then return end
    local idx = 1
    for i, name in ipairs(names) do
      if name == theme_name then idx = i; break end
    end
    local next_name = names[(idx % #names) + 1]
    local f, err = io.open(repo_path("theme.lua"), "w")
    if not f then
      wezterm.log_error("theme cycle: cannot write theme.lua: " .. tostring(err))
      return
    end
    f:write('return "' .. next_name .. '"\n')
    f:close()
    win:perform_action(act.ReloadConfiguration, pane)
  end) },

  -- Font cycling (Alt+F next / Alt+Shift+F prev) — see cycle_font above.
  { key = "f", mods = "ALT",       action = wezterm.action_callback(function(win, pane) cycle_font(win, pane, 1) end) },
  { key = "f", mods = "ALT|SHIFT", action = wezterm.action_callback(function(win, pane) cycle_font(win, pane, -1) end) },

  -- Command palette (Ctrl+Shift+P) — like VS Code
  { key = "p", mods = "CTRL|SHIFT", action = act.ActivateCommandPalette },

  -- Quick font size adjustment
  { key = "=", mods = "CTRL", action = act.IncreaseFontSize },
  { key = "-", mods = "CTRL", action = act.DecreaseFontSize },
  { key = "0", mods = "CTRL", action = act.ResetFontSize },

  -- Copy mode (like tmux)
  { key = "[", mods = "ALT", action = act.ActivateCopyMode },

  -- Search (Ctrl+Shift+F)
  { key = "f", mods = "CTRL|SHIFT", action = act.Search("CurrentSelectionOrEmptyString") },
}

-- ==========================================================================
--  KEY TABLES — Modal keybindings (enter a mode, act freely, Escape to exit)
-- ==========================================================================
-- resize_pane: entered with Alt+R. Tap h/j/k/l or arrows to resize continuously.
-- The status bar shows [RESIZE PANE] while in this mode.
config.key_tables = {
  resize_pane = {
    { key = "h",          action = act.AdjustPaneSize({ "Left",  3 }) },
    { key = "j",          action = act.AdjustPaneSize({ "Down",  3 }) },
    { key = "k",          action = act.AdjustPaneSize({ "Up",    3 }) },
    { key = "l",          action = act.AdjustPaneSize({ "Right", 3 }) },
    { key = "LeftArrow",  action = act.AdjustPaneSize({ "Left",  3 }) },
    { key = "DownArrow",  action = act.AdjustPaneSize({ "Down",  3 }) },
    { key = "UpArrow",    action = act.AdjustPaneSize({ "Up",    3 }) },
    { key = "RightArrow", action = act.AdjustPaneSize({ "Right", 3 }) },
    { key = "Escape", action = "PopKeyTable" },
    { key = "q",      action = "PopKeyTable" },
    { key = "Enter",  action = "PopKeyTable" },
  },
}

-- ==========================================================================
--  MOUSE — URL click, right-click paste
-- ==========================================================================
config.mouse_bindings = {
  -- Left-click release: complete selection / open link (plugins may override).
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "NONE",
    action = act.CompleteSelectionOrOpenLinkAtMouseCursor("ClipboardAndPrimarySelection"),
  },
  -- Ctrl+Click to open links
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "CTRL",
    action = act.OpenLinkAtMouseCursor,
  },
  -- Right click pastes from clipboard
  {
    event = { Down = { streak = 1, button = "Right" } },
    action = act.PasteFrom("Clipboard"),
  },
  -- Ctrl+Drag to move the window (Alt+Drag is column select — leave that alone)
  {
    event = { Drag = { streak = 1, button = "Left" } },
    mods = "CTRL",
    action = act.StartWindowDrag,
  },
}

-- ==========================================================================
--  MISC POLISH
-- ==========================================================================
config.automatically_reload_config = true
config.check_for_updates = false
config.status_update_interval = 1000
-- Dim inactive panes — strength depends on the theme's polarity: 0.7
-- brightness is a good dim on dark themes but turns light creams muddy
-- gray (owner-reported on paper, 2026-06-12), so light themes get a gentle
-- touch instead. Derived from the theme background, no theme field needed.
local function theme_bg_is_light()
  local r, g, b = theme.colors.background:match("^#(%x%x)(%x%x)(%x%x)$")
  return (0.2126 * tonumber(r, 16) + 0.7152 * tonumber(g, 16) + 0.0722 * tonumber(b, 16)) / 255 > 0.5
end
config.inactive_pane_hsb = theme_bg_is_light()
    and { saturation = 0.93, brightness = 0.93 }
    or  { saturation = 0.85, brightness = 0.7 }
config.switch_to_last_active_tab_when_closing_tab = true
config.warn_about_missing_glyphs = false
config.enable_kitty_keyboard = true

-- ==========================================================================
--  RIGHT STATUS — Shell type, git branch, date & time
-- ==========================================================================
wezterm.on("update-status", function(window, pane)
  local cells = {}

  -- Plugin status cells render leftmost, before the base cells; a provider
  -- returns FormatItem[] (including its own trailing separator) or nil.
  for _, provider in ipairs(status_cell_providers) do
    local ok, items = pcall(provider, window, pane, ctx)
    if not ok then
      wezterm.log_error("status cell failed: " .. tostring(items))
    elseif items then
      for _, item in ipairs(items) do table.insert(cells, item) end
    end
  end

  -- Active font indicator (font_name from the bootstrap; Alt+F cycles it).
  table.insert(cells, { Foreground = { Color = theme.ui.accent } })
  table.insert(cells, { Text = " \u{f031} " .. font_name })
  table.insert(cells, { Foreground = { Color = theme.ui.muted } })
  table.insert(cells, { Text = "  \u{2502}  " })

  -- Key table mode indicator (e.g. shows "[RESIZE PANE]" while Alt+R mode is active)
  local key_table = window:active_key_table()
  if key_table then
    local label = key_table:upper():gsub("_", " ")
    table.insert(cells, { Foreground = { Color = theme.ui.alert } })
    table.insert(cells, { Text = " [" .. label .. "]" })
    table.insert(cells, { Foreground = { Color = theme.ui.muted } })
    table.insert(cells, { Text = "  \u{2502}  " })
  end

  -- Shell type indicator (WSL vs native Windows)
  local domain = pane:get_domain_name()
  local shell_icon, shell_label
  if domain:find("^WSL:") then
    shell_icon = "\u{e712}"   --
    shell_label = domain:gsub("^WSL:", "")
  else
    shell_icon = "\u{e70f}"   --
    shell_label = "Windows"
  end
  table.insert(cells, { Foreground = { Color = theme.ui.statusline.shell } })
  table.insert(cells, { Text = " " .. shell_icon .. " " .. shell_label })

  -- Git branch (sent from shell via user var)
  local git_branch = pane:get_user_vars().gitbranch or ""
  if git_branch ~= "" then
    table.insert(cells, { Foreground = { Color = theme.ui.muted } })
    table.insert(cells, { Text = "  \u{2502}  " })
    table.insert(cells, { Foreground = { Color = theme.ui.statusline.git } })
    table.insert(cells, { Text = "\u{e725} " .. git_branch })
  end

  -- Date & time (12-hour with seconds)
  table.insert(cells, { Foreground = { Color = theme.ui.muted } })
  table.insert(cells, { Text = "  \u{2502}  " })
  table.insert(cells, { Foreground = { Color = theme.ui.statusline.clock } })
  table.insert(cells, { Text = wezterm.strftime("%a %b %-d  %I:%M:%S %p") .. " " })

  window:set_right_status(wezterm.format(cells))
end)

-- ==========================================================================
--  PLUGINS — loaded last so they may override base decisions; pcall-isolated
-- ==========================================================================
local plugin_paths = wezterm.glob(repo_path("plugins/*.lua"))
table.sort(plugin_paths)
for _, path in ipairs(plugin_paths) do
  wezterm.add_to_config_reload_watch_list(path)  -- dofile'd, so not auto-watched
  local ok, plugin = pcall(dofile, path)
  if ok and type(plugin) == "table" and type(plugin.apply) == "function" then
    local ok2, err = pcall(plugin.apply, config, ctx)
    if not ok2 then wezterm.log_error("plugin apply failed: " .. path .. ": " .. tostring(err)) end
  else
    wezterm.log_error("plugin load failed: " .. path .. ": " .. tostring(plugin))
  end
end

return config
