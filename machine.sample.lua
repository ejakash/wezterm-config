-- Per-machine values. Copy to machine.lua (gitignored) in the repo root and edit.
-- wezterm.lua refuses to start without machine.lua and names this file in its error.
return {
  windows_user     = "yourname",           -- Windows username: C:\Users\<windows_user>
  wsl_distro       = "Ubuntu-24.04",       -- `wsl -l -q` to list
  default_cwd      = "/mnt/d/labs",        -- starting dir for new windows/tabs/panes
  repo_dir_windows = "D:\\labs\\wezterm",  -- this repo, as a Windows path (theme assets, plugins)
}
