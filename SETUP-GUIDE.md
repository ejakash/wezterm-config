# WezTerm + Oh My Posh Terminal Setup Guide

A reproducible guide for setting up a polished WezTerm terminal on Windows with WSL. Designed to be read by a human or by an AI agent to replicate the setup on a new machine.

**Last updated:** 2026-04-14

---

## How To Use This Guide

### Setting up a new machine

If you are an AI agent reading this after the user asked you to set up their terminal:

1. Work through the **installation and configuration sections** in this guide from top to bottom (Install WezTerm, Install Nerd Font, Create WezTerm Config, Install Oh My Posh, Create Oh My Posh Theme, Configure .bashrc, Restart and Verify).
2. Once everything is installed and verified, read `CHANGELOG-SUMMARY.md` in this repo.
3. Look for any entries tagged `[optional]`. These are changes that were deliberately left out of the base setup — they may or may not apply to this machine.
4. Present each `[optional]` entry to the user with its description. Let them accept or skip each one.
5. For each accepted entry, read the linked changelog file in `changelogs/` and apply the change.

### Making future changes

After the initial setup, any new agent session opened in this project folder will automatically load `CLAUDE.md` (or `AGENTS.md` for non-Claude harnesses). These files instruct the agent on the workflow for making changes, creating changelogs, and classifying them. Just describe what you want changed — the agent handles the rest.

---

## What Does What — Visual Responsibility Map

Understanding which layer controls what helps when tweaking or debugging.

| Visual Element | Controlled By | Config File |
|---|---|---|
| Window chrome (title bar, borders, transparency, blur) | WezTerm | `.wezterm.lua` |
| Color scheme (background, text, ANSI colors) | WezTerm | `.wezterm.lua` |
| Font rendering (family, size, ligatures, line height) | WezTerm | `.wezterm.lua` |
| Tab bar (position, style, colors, tab titles) | WezTerm | `.wezterm.lua` |
| GPU-accelerated rendering (WebGpu) | WezTerm | `.wezterm.lua` |
| Cursor style and blink | WezTerm | `.wezterm.lua` |
| Keybindings (pane splits, tab nav, zoom, etc.) | WezTerm | `.wezterm.lua` |
| Mouse bindings (Ctrl+click URLs, right-click paste) | WezTerm | `.wezterm.lua` |
| Kitty keyboard protocol (Shift+Enter in apps) | WezTerm | `.wezterm.lua` |
| Right status bar (shell type, git branch, date/time) | WezTerm + Bash | `.wezterm.lua` + `.bashrc` |
| Inactive pane dimming | WezTerm | `.wezterm.lua` |
| Prompt segments (OS icon, user, path, git) | Oh My Posh | `theme.omp.json` |
| Prompt colors (Tokyo Night palette in prompt) | Oh My Posh | `theme.omp.json` |
| Right prompt (Node, Python, .NET, Go, Rust, K8s, exec time) | Oh My Posh | `theme.omp.json` |
| Powerline arrow shapes between segments | Oh My Posh | `theme.omp.json` |
| Transient prompt (collapse old prompts to `>`) | Oh My Posh | `theme.omp.json` |
| Prompt character (`>` / red on error) | Oh My Posh | `theme.omp.json` |
| Nerd Font icons/glyphs (git branch, folder, etc.) | Font files | Windows per-user fonts |
| Shell aliases, PATH, Claude Code wrapper | Bash | `.bashrc` |

---

## Prerequisites

- Windows 10/11 with WSL2 enabled
- A WSL Ubuntu distribution installed (e.g., `Ubuntu-24.04`)
- Internet access for downloads

---

## Step 1: Install WezTerm

Download and install WezTerm on **Windows** (not inside WSL):

1. Go to https://wezfurlong.org/wezterm/installation.html
2. Download the Windows installer (`.exe` or `.msi`)
3. Run the installer with default settings
4. Launch WezTerm once to verify it opens

---

## Step 2: Install Nerd Font Symbols

Nerd Font provides the icons/glyphs used throughout the prompt and UI. We install the **Symbols Nerd Font** as a fallback alongside JetBrains Mono.

### Automated (run from WSL)

```bash
# Download Symbols Nerd Font
FONT_DIR="/mnt/c/Users/$(cmd.exe /C 'echo %USERNAME%' 2>/dev/null | tr -d '\r')/AppData/Local/Microsoft/Windows/Fonts"
mkdir -p "$FONT_DIR"

curl -fLo /tmp/NerdFontsSymbolsOnly.zip \
  https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.zip

sudo apt-get install -y unzip
unzip -o /tmp/NerdFontsSymbolsOnly.zip -d /tmp/nerd-symbols

cp /tmp/nerd-symbols/SymbolsNerdFont-Regular.ttf "$FONT_DIR/"
cp /tmp/nerd-symbols/SymbolsNerdFontMono-Regular.ttf "$FONT_DIR/"

# Register fonts in Windows registry (per-user, no admin needed)
powershell.exe -NoProfile -Command "
  New-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts' \
    -Name 'Symbols Nerd Font Regular (TrueType)' \
    -Value 'SymbolsNerdFont-Regular.ttf' -PropertyType String -Force
  New-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts' \
    -Name 'Symbols Nerd Font Mono Regular (TrueType)' \
    -Value 'SymbolsNerdFontMono-Regular.ttf' -PropertyType String -Force
"

rm -rf /tmp/NerdFontsSymbolsOnly.zip /tmp/nerd-symbols
```

> **Note:** JetBrains Mono is bundled with WezTerm — no separate install needed.

---

## Step 3: Create the WezTerm Config

Create the file at the **Windows** path: `C:\Users\<USERNAME>\.wezterm.lua`

From WSL: `/mnt/c/Users/<USERNAME>/.wezterm.lua`

```lua
local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- ==========================================================================
--  DEFAULT SHELL: WSL Ubuntu
-- ==========================================================================
-- ADAPT: Change to match your WSL distro name (run: wsl.exe -l -q)
config.default_domain = "WSL:Ubuntu-24.04"

-- config.default_cwd does not work reliably for WSL domains. Use wsl_domains
-- to set the starting directory at the domain level instead.
-- ADAPT: Set default_cwd to your preferred starting directory.
-- ADAPT: Change "Ubuntu-24.04" to match your distro name (wsl.exe -l -q).
config.wsl_domains = {
  {
    name = "WSL:Ubuntu-24.04",
    distribution = "Ubuntu-24.04",
    default_cwd = "/path/to/your/projects",
  },
}

-- ==========================================================================
--  COLOR SCHEME — Tokyo Night (community favorite, easy on eyes)
-- ==========================================================================
config.color_scheme = "Tokyo Night"

-- ==========================================================================
--  FONT — JetBrains Mono with ligatures + fallback Nerd Font icons
-- ==========================================================================
config.font = wezterm.font_with_fallback({
  { family = "JetBrains Mono", weight = "Medium", harfbuzz_features = { "calt=1", "clig=1", "liga=1" } },
  { family = "Symbols Nerd Font Mono" },
  "Noto Color Emoji",
})
config.font_size = 11.5
config.line_height = 1.15
config.cell_width = 0.9

-- ==========================================================================
--  WINDOW — Borderless, semi-transparent, blurred background
-- ==========================================================================
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"  -- resize handles + clickable min/max/close in tab bar
config.window_background_opacity = 0.92
config.win32_system_backdrop = "Acrylic"      -- Windows 11 acrylic blur
config.window_padding = { left = 12, right = 12, top = 8, bottom = 4 }
config.initial_cols = 140
config.initial_rows = 38
config.window_close_confirmation = "NeverPrompt"

-- ==========================================================================
--  TAB BAR — Fancy bar at top, fully Tokyo Night themed
-- ==========================================================================
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 80

config.window_frame = {
  font = wezterm.font("JetBrains Mono", { weight = "Medium" }),
  font_size = 11.5,
  active_titlebar_bg   = "#1a1b26",
  inactive_titlebar_bg = "#16171f",
  border_left_color   = "#1a1b26",
  border_right_color  = "#1a1b26",
  border_top_color    = "#1a1b26",
  border_bottom_color = "#3b4261",
  button_fg         = "#565f89",
  button_bg         = "#1a1b26",
  button_hover_fg   = "#c0caf5",
  button_hover_bg   = "#292e42",
}

-- Custom tab title: index + process name
wezterm.on("format-tab-title", function(tab)
  local title = tab.active_pane.title
  if #title > 72 then
    title = title:sub(1, 70) .. ".."
  end
  local index = tab.tab_index + 1
  return string.format("  %d: %s  ", index, title)
end)

-- ==========================================================================
--  COLORS — Custom tab bar colors to match Tokyo Night
-- ==========================================================================
config.colors = {
  scrollbar_thumb = "#3b4261",
  tab_bar = {
    background = "#1a1b26",
    active_tab = {
      bg_color = "#7aa2f7",
      fg_color = "#1a1b26",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#24283b",
      fg_color = "#565f89",
    },
    inactive_tab_hover = {
      bg_color = "#292e42",
      fg_color = "#c0caf5",
    },
  },
}

-- ==========================================================================
--  CURSOR
-- ==========================================================================
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = "EaseIn"
config.cursor_blink_ease_out = "EaseOut"
config.force_reverse_video_cursor = false

-- ==========================================================================
--  SCROLLBACK & PERFORMANCE
-- ==========================================================================
config.scrollback_lines = 10000
config.enable_scroll_bar = true
config.min_scroll_bar_height = "1cell"
config.max_fps = 120
config.animation_fps = 60
config.front_end = "WebGpu"                   -- GPU-accelerated rendering

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
local act = wezterm.action

-- Pick a safe CWD for new panes. Tolerates all three shapes WezTerm has returned over the years
-- (nil, plain string URL, {file_path=...}) and rejects Windows paths that would fail WSL chdir.
local FALLBACK_CWD = "/mnt/d/labs"
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
  if path:match("^%a:[/\\]") or path:match("^\\\\") then return FALLBACK_CWD end
  return path
end

config.keys = {
  -- Pane splitting — new panes inherit the active pane's CWD via OSC 7 (see .bashrc)
  -- Alt+/  = split right (side by side)
  -- Alt+.  = split down (stacked)
  { key = "/", mods = "ALT", action = wezterm.action_callback(function(win, pane)
    win:perform_action(act.SplitHorizontal({ domain = "CurrentPaneDomain", cwd = resolve_cwd(pane) }), pane)
  end) },
  { key = ".", mods = "ALT", action = wezterm.action_callback(function(win, pane)
    win:perform_action(act.SplitVertical({ domain = "CurrentPaneDomain", cwd = resolve_cwd(pane) }), pane)
  end) },

  -- Pane navigation — Alt+arrows for all four directions
  { key = "LeftArrow",  mods = "ALT", action = act.ActivatePaneDirection("Left") },
  { key = "RightArrow", mods = "ALT", action = act.ActivatePaneDirection("Right") },
  { key = "UpArrow",    mods = "ALT", action = act.ActivatePaneDirection("Up") },
  { key = "DownArrow",  mods = "ALT", action = act.ActivatePaneDirection("Down") },
  -- Tab navigation — Ctrl+Tab / Ctrl+Shift+Tab (see below) and Alt+1-5

  -- Pane resize:
  --   Alt+R            → enter resize mode (tap arrows freely, Escape exits)
  --   Alt+Shift+arrows → one-shot resize without entering a mode
  { key = "r", mods = "ALT", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },
  { key = "LeftArrow",  mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Left",  3 }) },
  { key = "RightArrow", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Right", 3 }) },
  { key = "UpArrow",    mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Up",    3 }) },
  { key = "DownArrow",  mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Down",  3 }) },

  -- Rotate panes clockwise within the current tab (Alt+O)
  { key = "o", mods = "ALT", action = act.RotatePanes("Clockwise") },

  -- Close pane (Ctrl+Shift+W)
  { key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = false }) },

  -- New tab — SpawnTab("CurrentPaneDomain") can't reliably pass CWD to a new
  -- WSL process, so use SpawnCommandInNewTab with an explicit cwd instead.
  -- ADAPT: Match the domain name and cwd to your machine.
  { key = "t", mods = "CTRL|SHIFT", action = act.SpawnCommandInNewTab({
    domain = { DomainName = "WSL:Ubuntu-24.04" },
    cwd = "/path/to/your/projects",
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
config.inactive_pane_hsb = { saturation = 0.85, brightness = 0.7 }  -- dim inactive panes
config.switch_to_last_active_tab_when_closing_tab = true
config.warn_about_missing_glyphs = false

-- Kitty keyboard protocol: lets apps (like Claude Code) receive enhanced key
-- events (e.g., Shift+Enter as distinct from Enter) while keeping normal
-- behavior in the regular shell.
config.enable_kitty_keyboard = true

-- ==========================================================================
--  RIGHT STATUS — Shell type, git branch, date & time
-- ==========================================================================
wezterm.on("update-status", function(window, pane)
  local cells = {}

  -- Key table mode indicator (e.g. shows "[RESIZE PANE]" while Alt+R mode is active)
  local key_table = window:active_key_table()
  if key_table then
    local label = key_table:upper():gsub("_", " ")
    table.insert(cells, { Foreground = { Color = "#f7768e" } })
    table.insert(cells, { Text = " [" .. label .. "]" })
    table.insert(cells, { Foreground = { Color = "#565f89" } })
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
  table.insert(cells, { Foreground = { Color = "#7dcfff" } })
  table.insert(cells, { Text = " " .. shell_icon .. " " .. shell_label })

  -- Git branch (sent from shell via user var — see .bashrc setup)
  local git_branch = pane:get_user_vars().gitbranch or ""
  if git_branch ~= "" then
    table.insert(cells, { Foreground = { Color = "#565f89" } })
    table.insert(cells, { Text = "  \u{2502}  " })
    table.insert(cells, { Foreground = { Color = "#bb9af7" } })
    table.insert(cells, { Text = "\u{e725} " .. git_branch })
  end

  -- Date & time (12-hour with seconds)
  table.insert(cells, { Foreground = { Color = "#565f89" } })
  table.insert(cells, { Text = "  \u{2502}  " })
  table.insert(cells, { Foreground = { Color = "#c0caf5" } })
  table.insert(cells, { Text = wezterm.strftime("%a %b %-d  %I:%M:%S %p") .. " " })

  window:set_right_status(wezterm.format(cells))
end)

return config
```

### Things to adapt on a new machine

- **`default_domain` / `wsl_domains`**: Run `wsl.exe -l -q` and use the exact distro name for both fields.
- **`default_cwd`** (inside `wsl_domains`): Set to your preferred starting directory (e.g. `/mnt/d/labs`). Use `wsl_domains` for this — `config.default_cwd` does not work for WSL domains.
- **`win32_system_backdrop`**: Only works on Windows 11. On Windows 10, remove this line.

---

## Step 4: Install Oh My Posh (inside WSL)

```bash
curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin
```

---

## Step 5: Create the Oh My Posh Theme

Create at: `~/.config/oh-my-posh/theme.omp.json`

```bash
mkdir -p ~/.config/oh-my-posh
```

Then write this content to `~/.config/oh-my-posh/theme.omp.json`:

```json
{
  "$schema": "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json",
  "version": 3,
  "final_space": true,
  "console_title_template": "{{ .Folder }}{{ if .Root }} :: root{{ end }}",
  "palette": {
    "blue": "#7aa2f7",
    "magenta": "#bb9af7",
    "green": "#9ece6a",
    "red": "#f7768e",
    "orange": "#ff9e64",
    "cyan": "#7dcfff",
    "fg": "#c0caf5",
    "bg_dark": "#1a1b26",
    "bg": "#24283b",
    "bg_light": "#292e42",
    "muted": "#565f89",
    "yellow": "#e0af68"
  },
  "blocks": [
    {
      "type": "prompt",
      "alignment": "left",
      "newline": true,
      "segments": [
        {
          "type": "os",
          "style": "diamond",
          "leading_diamond": "\ue0b6",
          "foreground": "p:cyan",
          "background": "p:bg",
          "template": " {{ if .WSL }}\ue712{{ else }}{{ .Icon }}{{ end }} "
        },
        {
          "type": "session",
          "style": "powerline",
          "powerline_symbol": "\ue0b0",
          "foreground": "p:fg",
          "background": "p:bg_light",
          "template": " {{ .UserName }} "
        },
        {
          "type": "path",
          "style": "powerline",
          "powerline_symbol": "\ue0b0",
          "foreground": "p:bg_dark",
          "background": "p:blue",
          "properties": {
            "style": "agnoster_short",
            "max_depth": 3,
            "hide_root_location": false,
            "folder_icon": "\uf115",
            "home_icon": "\uf015"
          },
          "template": " {{ .Path }} "
        },
        {
          "type": "git",
          "style": "powerline",
          "powerline_symbol": "\ue0b0",
          "foreground": "p:bg_dark",
          "background": "p:green",
          "background_templates": [
            "{{ if or (.Working.Changed) (.Staging.Changed) }}p:orange{{ end }}",
            "{{ if gt .Ahead 0 }}p:cyan{{ end }}",
            "{{ if gt .Behind 0 }}p:red{{ end }}"
          ],
          "properties": {
            "branch_icon": "\ue725 ",
            "cherry_pick_icon": "\ue29b ",
            "commit_icon": "\uf417 ",
            "fetch_status": true,
            "fetch_upstream_icon": true,
            "merge_icon": "\ue727 ",
            "no_commits_icon": "\uf0c3 ",
            "rebase_icon": "\ue728 ",
            "revert_icon": "\uf0e2 ",
            "tag_icon": "\uf412 "
          },
          "template": " {{ .HEAD }}{{ if .BranchStatus }} {{ .BranchStatus }}{{ end }}{{ if .Working.Changed }} \uf044 {{ .Working.String }}{{ end }}{{ if .Staging.Changed }} \uf046 {{ .Staging.String }}{{ end }}{{ if gt .StashCount 0 }} \uf692 {{ .StashCount }}{{ end }} "
        },
        {
          "type": "text",
          "style": "powerline",
          "powerline_symbol": "\ue0b0",
          "foreground": "transparent",
          "background": "transparent",
          "template": ""
        }
      ]
    },
    {
      "type": "rprompt",
      "segments": [
        {
          "type": "node",
          "style": "diamond",
          "leading_diamond": "\ue0b6",
          "trailing_diamond": "\ue0b4",
          "foreground": "p:green",
          "background": "p:bg",
          "properties": { "fetch_package_manager": true, "display_mode": "context" },
          "template": " \ue718 {{ .Full }} "
        },
        {
          "type": "python",
          "style": "diamond",
          "leading_diamond": "\ue0b6",
          "trailing_diamond": "\ue0b4",
          "foreground": "p:yellow",
          "background": "p:bg",
          "properties": { "display_mode": "context", "fetch_virtual_env": true },
          "template": " \ue235 {{ if .Venv }}{{ .Venv }} {{ end }}{{ .Full }} "
        },
        {
          "type": "dotnet",
          "style": "diamond",
          "leading_diamond": "\ue0b6",
          "trailing_diamond": "\ue0b4",
          "foreground": "p:magenta",
          "background": "p:bg",
          "properties": { "display_mode": "context" },
          "template": " \ue77f {{ .Full }} "
        },
        {
          "type": "go",
          "style": "diamond",
          "leading_diamond": "\ue0b6",
          "trailing_diamond": "\ue0b4",
          "foreground": "p:cyan",
          "background": "p:bg",
          "properties": { "display_mode": "context" },
          "template": " \ue626 {{ .Full }} "
        },
        {
          "type": "rust",
          "style": "diamond",
          "leading_diamond": "\ue0b6",
          "trailing_diamond": "\ue0b4",
          "foreground": "p:orange",
          "background": "p:bg",
          "properties": { "display_mode": "context" },
          "template": " \ue7a8 {{ .Full }} "
        },
        {
          "type": "kubectl",
          "style": "diamond",
          "leading_diamond": "\ue0b6",
          "trailing_diamond": "\ue0b4",
          "foreground": "p:blue",
          "background": "p:bg",
          "properties": { "display_mode": "context" },
          "template": " \ufd31 {{ .Context }}{{ if .Namespace }}/{{ .Namespace }}{{ end }} "
        },
        {
          "type": "executiontime",
          "style": "diamond",
          "leading_diamond": "\ue0b6",
          "trailing_diamond": "\ue0b4",
          "foreground": "p:muted",
          "background": "p:bg",
          "properties": { "threshold": 2000, "style": "roundrock" },
          "template": " \uf253 {{ .FormattedMs }} "
        }
      ]
    },
    {
      "type": "prompt",
      "alignment": "left",
      "newline": true,
      "segments": [
        {
          "type": "text",
          "style": "plain",
          "foreground_templates": [ "{{ if gt .Code 0 }}p:red{{ end }}" ],
          "foreground": "p:magenta",
          "template": "\u276f "
        }
      ]
    }
  ],
  "transient_prompt": {
    "foreground_templates": [ "{{ if gt .Code 0 }}p:red{{ end }}" ],
    "foreground": "p:magenta",
    "template": "\u276f "
  },
  "secondary_prompt": {
    "foreground": "p:muted",
    "template": "\u276f\u276f "
  }
}
```

---

## Step 6: Configure .bashrc

### Install shell tool dependencies

```bash
sudo apt-get install -y fzf fd-find
```

These are required for the smart `cd` picker (see below). The picker silently no-ops if either package is missing, so this step is safe to skip — but the feature won't work without them.

### Add the following at the **end** of `~/.bashrc`:

```bash
# claude code
export PATH="$HOME/.local/bin:$PATH"
claude() { command claude "$@"; printf '\033[J'; }

# opencode (optional — remove if not used)
export PATH="$HOME/.opencode/bin:$PATH"

# Windows .NET (optional — only if using .NET from WSL)
alias dotnet='dotnet.exe'

# Send git branch + CWD to WezTerm
# WEZTERM_* env vars are more reliable than TERM_PROGRAM (tmux/VS Code can clobber it).
# OSC 7 uses literal "localhost" — WezTerm rejects URLs whose hostname doesn't match the
# host it thinks it's on, and WSL's /etc/hostname can differ from the Windows hostname.
__wezterm_set_user_vars() {
  if [[ -n "$WEZTERM_EXECUTABLE" || -n "$WEZTERM_PANE" || "$TERM_PROGRAM" == "WezTerm" ]]; then
    local branch
    branch=$(git branch --show-current 2>/dev/null)
    printf "\033]1337;SetUserVar=gitbranch=%s\007" "$(printf '%s' "${branch:-}" | base64 -w0)"
    printf "\033]7;file://localhost%s\033\\" "$PWD"
  fi
}
PROMPT_COMMAND="__wezterm_set_user_vars;${PROMPT_COMMAND:-}"

# Oh My Posh prompt
eval "$(~/.local/bin/oh-my-posh init bash --config ~/.config/oh-my-posh/theme.omp.json)"

# smart-cd: fuzzy interactive directory picker (interactive shells only)
# SMART_CD_ROOT is machine-specific — ask the user where their code/projects live
# (e.g. "$HOME/source", "/mnt/d", "/mnt/c/dev") and set it below before sourcing.
if command -v fzf >/dev/null 2>&1 && { command -v fd >/dev/null 2>&1 || command -v fdfind >/dev/null 2>&1; }; then

  SMART_CD_ROOT="$HOME/source"   # <-- edit per machine

  __smart_cd_pick() {
    local FD target
    FD=$(command -v fd || command -v fdfind) || return 1
    target=$(
      "$FD" . "$SMART_CD_ROOT" \
        --type d --max-depth 5 --hidden \
        --exclude .git --exclude node_modules --exclude bin --exclude obj \
        --exclude .cache --exclude .local --exclude .npm --exclude .cargo \
        --exclude .venv --exclude venv --exclude dist --exclude build \
        --exclude target --exclude Downloads --exclude Pictures \
        --exclude Videos --exclude Music \
        2>/dev/null |
      sed "s|^$SMART_CD_ROOT/||" |
      fzf --height 50% --reverse --prompt="cd> " --query="${*:-}"
    )
    [ -n "$target" ] && builtin cd "$SMART_CD_ROOT/$target"
  }

  cd() {
    if [[ $- != *i* ]]; then
      builtin cd "$@"
      return
    fi

    if [ $# -eq 0 ]; then
      __smart_cd_pick
      return
    fi

    if [ -d "$1" ] || [ -f "$1" ] || [[ "$1" == .* ]] || [[ "$1" == /* ]] || [[ "$1" == ~* ]]; then
      builtin cd "$@"
      return
    fi

    __smart_cd_pick "$*"
  }

fi
# end smart-cd
```

### Shell additions explained

| Addition | Purpose |
|---|---|
| `PATH += ~/.local/bin` | Makes Claude Code and Oh My Posh accessible |
| `claude() { ... printf '\033[J'; }` | Clears leftover TUI rendering after Claude Code exits. `ESC[J` erases from cursor to bottom of screen without clearing scrollback. |
| `__wezterm_set_user_vars` | Sends the current git branch (OSC 1337 user var) and current working directory (OSC 7, using `localhost`) to WezTerm on each prompt. OSC 7 is what makes `pane:get_current_working_dir()` work, which the `Alt+/` / `Alt+.` split-pane keybindings rely on. Guarded by `WEZTERM_*` env vars (more reliable than `TERM_PROGRAM`, which wrappers can clobber). Must come **before** Oh My Posh init. |
| `eval "$(oh-my-posh init bash ...)"` | Activates the Oh My Posh prompt, replacing the default PS1. **Must be the last line** to ensure it overrides any earlier prompt setup. |
| `cd` wrapper (`smart-cd`) | Replaces `cd` in interactive shells with a fuzzy picker backed by `fdfind` + `fzf`. `cd` with no args or an unknown path opens the picker searching `$SMART_CD_ROOT`. **`SMART_CD_ROOT` is machine-specific** — during setup, ask the user where their code lives (e.g. `$HOME/source`, `/mnt/d`, `/mnt/c/dev`) and set it in the block above. Existing paths, absolute paths, `..`, and `~` prefixes pass straight through to `builtin cd`. Silently disabled if `fzf` or `fdfind` is not installed. |

---

## Step 7: Restart and Verify

1. Close all WezTerm windows completely
2. Relaunch WezTerm
3. Verify checklist:
   - [ ] Opens directly into WSL Ubuntu
   - [ ] Powerline prompt with OS icon, username, path, git info
   - [ ] Nerd Font icons render (no boxes/question marks)
   - [ ] Semi-transparent window with acrylic blur
   - [ ] Tab bar at top, always visible, with min/max/close buttons in top-right
   - [ ] `Alt+/` splits pane right (side by side)
   - [ ] `Alt+.` splits pane down (stacked)
   - [ ] `Alt+arrows` moves focus between panes
   - [ ] `Alt+R` enters resize mode, arrow keys resize, `Escape` exits; status bar shows `[RESIZE PANE]`
   - [ ] `Ctrl+Tab` / `Ctrl+Shift+Tab` switch tabs
   - [ ] Right prompt shows language version when in a project dir
   - [ ] `Shift+Enter` creates newline in Claude Code
   - [ ] Status bar shows shell type (e.g., ` Ubuntu-24.04`)
   - [ ] Status bar shows git branch when inside a repo
   - [ ] Status bar shows 12-hour time with seconds
   - [ ] Exiting Claude Code leaves no visual artifacts
   - [ ] `cd liceapi` opens the fuzzy picker with "liceapi" pre-typed (requires `fzf` + `fd-find`)

---

## Keybinding Cheat Sheet

### Pane Splitting
| Shortcut | Action |
|---|---|
| `Alt + /` | Split right (side by side) |
| `Alt + .` | Split down (stacked) |

### Pane Navigation
| Shortcut | Action |
|---|---|
| `Alt + Left` / `Alt + Right` | Move focus left / right |
| `Alt + Up` / `Alt + Down` | Move focus up / down |

### Pane Resizing
| Shortcut | Action |
|---|---|
| `Alt + R` | Enter resize mode — tap arrows freely; `Escape`/`q`/`Enter` exits |
| `Alt + Shift + Arrow` | One-shot resize by 3 cells (no mode needed) |

### Pane Management
| Shortcut | Action |
|---|---|
| `Alt + Z` | Toggle pane zoom (fills window, press again to restore) |
| `Alt + O` | Rotate panes clockwise in the current tab |
| `Ctrl + Shift + W` | Close current pane |

### Tabs
| Shortcut | Action |
|---|---|
| `Ctrl + Shift + T` | New tab |
| `Alt + Left` / `Alt + Right` | Move pane focus left / right |
| `Ctrl + Tab` / `Ctrl + Shift + Tab` | Next / previous tab |
| `Alt + 1-5` | Jump to tab by number |

### Other
| Shortcut | Action |
|---|---|
| `Ctrl + Shift + P` | Command palette |
| `Ctrl + =` / `-` / `0` | Font size: increase / decrease / reset |
| `Alt + [` | Enter copy mode (tmux-style) |
| `Ctrl + Shift + F` | Search |
| `Ctrl + Click` | Open URL |
| `Right Click` | Paste from clipboard |
| `Ctrl + Drag` | Move window (no title bar to drag) |

---

## Changelog

- **2026-04-14** — Pane splitting power-user setup: CWD-aware splits (new pane inherits current directory), `Alt+H/J/K/L` vim-style navigation, `Alt+R` modal resize mode with status bar indicator, `Alt+O` rotate panes.
- **2026-04-14** — Smart `cd` wrapper: fuzzy directory picker via `fdfind` + `fzf`, searching `~/source`. Falls back to `builtin cd` for real paths, absolute paths, and non-interactive shells.
- **2026-04-10** — Tab bar moved to top, switched to fancy style with per-tab close buttons, INTEGRATED_BUTTONS for clickable window controls, fully Tokyo Night themed via `window_frame`. Added Ctrl+Drag to move window.
- **2026-04-10** — Synced scrollbar settings: enabled scrollbar, added `min_scroll_bar_height`, added `scrollbar_thumb` color to match Tokyo Night palette.
- **2026-04-10** — Fixed default starting directory for new windows and tabs: switched from `config.default_cwd` (which doesn't work for WSL domains) to `config.wsl_domains[].default_cwd`.
- **2026-04-04** — Added vertical scrollbar with Tokyo Night-aligned thumb styling and larger minimum drag target.
- **2026-03-30** — Remapped Alt+Left/Right to tab navigation, moved pane focus to Ctrl+Alt+Left/Right.
- **2026-03-28** — Enhanced status bar: shell type indicator (WSL vs Windows), git branch via OSC user vars, 12-hour clock with seconds, brighter time color. Wider tabs (max 80, title truncation at 72 chars).
- **2026-03-28** — Initial setup: WezTerm config (Tokyo Night, borderless, acrylic, WebGpu, retro tab bar, keybindings), Nerd Font symbols, Oh My Posh theme (powerline prompt with git + language segments), kitty keyboard protocol for Shift+Enter support, Claude Code exit cleanup wrapper.
