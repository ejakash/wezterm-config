# Split pane: inherit current pane's CWD

## Goal

New panes opened via Alt+/ or Alt+. were starting in `/mnt/c/Users/AkashJohny` instead of a useful directory. User wanted new panes to open in the same directory as the active pane, with `~/source/local` as the fallback.

## Root cause

`pane:get_current_working_dir()` relies on the shell emitting **OSC 7** sequences on each prompt. The `.bashrc` was emitting the git branch via user vars but had no OSC 7, so WezTerm had no CWD data and returned a stale Windows path — causing `CreateProcessCommon: chdir failed 2`.

## Change

**`.bashrc`** — added OSC 7 emission inside `__wezterm_set_user_vars`:

```bash
# OSC 7: tells WezTerm the shell's current directory so pane:get_current_working_dir() works
printf "\033]7;file://%s%s\033\\" "$(hostname)" "$PWD"
```

**`.wezterm.lua`** — replaced simple `SplitHorizontal/SplitVertical` with `action_callback` that reads the now-reliable CWD:

```lua
{ key = "/", mods = "ALT", action = wezterm.action_callback(function(win, pane)
  local cwd_url = pane:get_current_working_dir()
  local cwd = (cwd_url and cwd_url.file_path) or "/home/akash/source/local"
  win:perform_action(act.SplitHorizontal({ domain = "CurrentPaneDomain", cwd = cwd }), pane)
end) },
{ key = ".", mods = "ALT", action = wezterm.action_callback(function(win, pane)
  local cwd_url = pane:get_current_working_dir()
  local cwd = (cwd_url and cwd_url.file_path) or "/home/akash/source/local"
  win:perform_action(act.SplitVertical({ domain = "CurrentPaneDomain", cwd = cwd }), pane)
end) },
```

## Notes

- OSC 7 fires on every prompt via `PROMPT_COMMAND`, keeping WezTerm's CWD in sync.
- The `or "/home/akash/source/local"` is a nil-check only — with OSC 7 working, it won't fire in normal use.
- OSC 7 format: `\e]7;file://hostname/path\e\\` (string terminator, not BEL, avoids issues in some terminals).

## Verification

`cd` to a project dir, hit Alt+/ — new pane opens in same directory.
