# plugins/ — cross-cutting drop-ins

`wezterm.lua` loads every `*.lua` in this directory (sorted filename order) **after**
all of its own sections, so plugins may override base decisions. Files here are
gitignored — they are installed by sibling repos (e.g. claude-waiting-notification),
not tracked here.

## Contract

````lua
local M = {}
function M.apply(config, ctx)
  -- config               wezterm config_builder() table; safe to set keys and to
  --                      table.insert into config.keys / config.mouse_bindings
  -- ctx.wezterm          the wezterm module
  -- ctx.machine          machine.lua table (windows_user, wsl_distro, default_cwd, repo_dir_windows)
  -- ctx.theme            active theme table; take ALL colors from ctx.theme.ui
  -- ctx.render_segment(opts)  build one status segment -> FormatItem[]. Design-
  --                      agnostic: today it renders a rounded "pill" chip, but the
  --                      look lives only in this function — plugins never change if
  --                      the bar is restyled. opts = { text = label, fg = text color,
  --                      chip = fill color (default ctx.theme.ui.statusline.chip),
  --                      bold = bool, gap = trailing space, default true }. The base
  --                      bar and every plugin use this one renderer.
  -- ctx.add_tab_overlay(fn)  register fn(tab, label, ctx) -> FormatItem[] | nil
  -- ctx.add_status_cell(fn)  register fn(window, pane, ctx) -> FormatItem[] | nil;
  --                      called each update-status tick; cells render leftmost in
  --                      the right-status area, before the base cells. Render your
  --                      segment with ctx.render_segment so it matches the bar (it carries
  --                      its own trailing gap). Return nil to render nothing this tick.
end
return M
````

Loading is pcall-wrapped: a broken plugin logs via `wezterm.log_error` and is skipped.
Overlays run in registration order inside the single `format-tab-title` handler;
first non-nil return wins; nil falls through to theme default styling.
Status cells likewise run in registration order; all non-nil results are concatenated.
Mouse-binding note: if two plugins bind the same (event, mods), the later-loaded
one silently wins — coordinate same-event bindings across plugins.
