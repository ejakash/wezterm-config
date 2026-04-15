# Split pane CWD inheritance: robustness tweaks

## Goal

No functional change. Harden the OSC 7 + `resolve_cwd` pipeline so it tolerates machine-to-machine variance (corporate hostname rewrites, wrapper shells, older/newer WezTerm return types).

## Background

`CHANGELOG-2026-04-14-split-pane-inherit-cwd.md` introduced CWD inheritance for `Alt+/` and `Alt+.`. It worked on the home PC but silently fell back to the hardcoded directory on a work PC with the same topology. See `diagnostics/split-pane-cwd-inheritance.md` for the full diagnosis.

## Changes

**`.bashrc`**

- OSC 7 guard now triggers on `WEZTERM_EXECUTABLE` or `WEZTERM_PANE` in addition to `TERM_PROGRAM == "WezTerm"`. Wrappers (tmux, VS Code terminal, screen) sometimes clobber `TERM_PROGRAM`; the `WEZTERM_*` vars are set directly by WezTerm and are more reliable.
- OSC 7 URL now uses the literal `localhost` instead of `$(hostname)`. WezTerm only accepts the URL as a local CWD if the hostname in it matches the machine. Corporate-imaged PCs often have WSL `/etc/hostname` ≠ Windows hostname, which silently disqualifies the URL. `localhost` is always accepted.

**`.wezterm.lua`**

- Extracted `resolve_cwd(pane)` helper with `FALLBACK_CWD = "/mnt/d/labs"` at the top.
- Tolerates all three shapes `pane:get_current_working_dir()` has returned over time: nil, plain string URL, or `{file_path=..., host=...}` object.
- Rejects Windows-style paths (`C:\...`, `\\server\...`) that would fail WSL chdir — returns fallback instead.
- Wrapped the call in `pcall` so an API change never aborts the keybinding.

## Additional finding (home PC, 2026-04-15)

The original `resolve_cwd` implementation used `type(cwd_url) == "table"` to detect the WezTerm Uri object. This was wrong — WezTerm returns a **Uri userdata** (`type()` returns `"userdata"`, not `"table"`), so the branch never matched and the function always returned `FALLBACK_CWD`.

Correct check: `type(cwd_url) == "userdata" or type(cwd_url) == "table"` (table kept for safety in case an older build returns one). The `.file_path` field is accessible on the userdata object directly.

Also confirmed: `TERM_PROGRAM=WezTerm` is set in WSL shells, so the OSC 7 guard in `.bashrc` fires correctly without needing `WEZTERM_EXECUTABLE` or `WEZTERM_PANE` on this machine. Those extra guards remain for robustness on machines where `TERM_PROGRAM` is clobbered.

## Verification

Home PC (2026-04-15): `cd` to a project dir, hit `Alt+/` — new pane opens in the same directory. Confirmed working after the userdata type fix.
