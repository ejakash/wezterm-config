-- Per-machine values. Copy to machine.lua (gitignored) in the repo root and edit.
-- wezterm.lua refuses to start without machine.lua and names this file in its error.
return {
  windows_user     = "yourname",           -- Windows username: C:\Users\<windows_user>
  wsl_distro       = "Ubuntu-24.04",       -- `wsl -l -q` to list
  default_cwd      = "/mnt/d/labs",        -- starting dir for new windows/tabs/panes
  repo_dir_windows = "D:\\labs\\wezterm",  -- this repo, as a Windows path (theme assets, plugins)

  -- Optional. Extra font-fallback entries spliced in after the primary family and
  -- before the icon/emoji fallbacks — the home for per-machine locale fonts the
  -- public config shouldn't carry. Each entry is a wezterm.font_with_fallback spec,
  -- e.g. { family = "Noto Sans Malayalam", scale = 0.95 }. Default: none.
  font_fallback    = {},
}
