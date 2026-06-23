# Verify checklist — behavioral verification of the full setup

Walk this after a fresh install or a significant change. Headless load check first:

```bash
"/mnt/c/Program Files/WezTerm/wezterm.exe" --config-file 'D:\labs\wezterm\wezterm.lua' ls-fonts
```

Expected: font listing, exit 0. A config-error message instead is a FAIL.

## Tab bar & theme

- [ ] Tab bar is transparent retro style — no solid blocks behind tabs, background image shows through.
- [ ] Active tab is bold accent-colored text (cyan on cyberdream); inactive tabs are dim blue.
- [ ] Theme round-trip: `echo 'return "tokyo-night"' > theme.lua` → auto-reload to fancy bar with integrated window buttons, opaque Tokyo Night colors, visible scrollbar. `rm theme.lua` → cyberdream returns. (First-time creation of theme.lua may not trigger the watcher — `touch wezterm.lua` to force.)
- [ ] `Alt+T` cycles to the next theme (sorted themes/*.lua: cyberdream → paper → tokyo-night) — full hot-swap including the case where theme.lua didn't exist yet; cycling wraps around to the first theme.

## Panes

- [ ] `Alt+/` splits right, `Alt+.` splits down — both open in the current pane's directory (OSC 7 inheritance).
- [ ] `Alt+arrows` move pane focus in all four directions.
- [ ] `Alt+R` enters resize mode — status bar shows `[RESIZE PANE]`; h/j/k/l or arrows resize repeatedly; `Escape` exits and the indicator disappears.
- [ ] `Alt+O` rotates panes clockwise.
- [ ] `Alt+Z` toggles pane zoom.
- [ ] `Ctrl+Shift+W` closes the current pane without confirmation.

## Tabs

- [ ] `Ctrl+Tab` / `Ctrl+Shift+Tab` cycle tabs forward/back.
- [ ] `Alt+1`–`Alt+5` jump directly to tabs 1–5.
- [ ] `Ctrl+Shift+T` opens a new tab in `default_cwd` (from machine.lua), not the Windows home.

## Scrollback

- [ ] `Shift+Up/Down` scrolls one line.
- [ ] `Ctrl+Shift+Up/Down` scrolls a quarter page.

## Mouse

- [ ] Right-click pastes from clipboard.
- [ ] `Ctrl+Click` on a URL opens it.
- [ ] `Ctrl+Drag` moves the window (no title bar on cyberdream).
- [ ] Left-click release completes a selection (copies to clipboard).

## Status bar

- [ ] Distro icon + name shown (WSL penguin/distro vs Windows).
- [ ] Git branch appears when inside a repo (sent from fish via user var); disappears outside.
- [ ] Clock shows date + 12-hour time with seconds, ticking.
- [ ] `[RESIZE PANE]` indicator renders in the theme's alert color while Alt+R mode is active.

## Claude-waiting plugin

- [ ] Suppression: Claude goes idle in the active pane of a focused window → no notification at all.
- [ ] Backgrounded: Claude goes idle in a background tab → tab turns amber, pane background tints, Windows toast fires. (The tint is only visible on themes with an opaque color background, e.g. tokyo-night or paper; a background image, e.g. cyberdream's, masks it.)
- [ ] Unfocused window: tab auto-switches to the waiting one and the window is raised.
- [ ] Click in a waiting non-TUI pane clears the amber/tint. (TUI apps that capture the mouse defeat click-clear — expected.)
- [ ] Dwell-clear: parking on the waiting pane for ~3s clears it.
- [ ] Submitting a prompt to Claude clears the waiting state.
- [ ] `Alt+N` jumps to the next waiting pane across tabs.

## Theme propagation (Claude Code)

- [ ] Scripted (run with bash; uses a /tmp skeleton — never touches the live `theme.lua`): every theme prints `ok`:

  ```bash
  R=$TERMINAL_REPO_DIR; T=/tmp/theme-export-check
  mkdir -p $T; ln -sfn "$R/themes" $T/themes; cp "$R/theme.sample.lua" $T/
  for f in "$R"/themes/*.lua; do
    n=$(basename "$f" .lua); echo "return \"$n\"" > $T/theme.lua
    TERMINAL_REPO_DIR=$T lua "$R/integrations/claude-code/theme-export.lua" --bash >/dev/null &&
    TERMINAL_REPO_DIR=$T lua "$R/integrations/claude-code/theme-export.lua" --cc-theme | python3 -m json.tool >/dev/null &&
    echo "ok: $n" || echo "FAIL: $n"
  done
  ```
- [ ] `Alt+T` → the Claude Code statusline recolors on its next refresh (a few seconds).
- [ ] `Alt+T` → most Claude Code colors follow without a session restart (`~/.claude/themes/wezterm.json` flips). Known limitation: a few elements keep the old theme until `/theme` → re-select `wezterm` — Claude Code's watcher re-applies overrides but not everything (verified 2026-06-12; no programmatic full re-apply exists).
- [ ] Fallback: `echo '{}' | TERMINAL_REPO_DIR= bash ~/.claude/statusline-command.sh | cat -v | head -1` renders in Tokyo Night defaults (contains `48;2;36;40;59`).

## Theme propagation (prompt)

- [ ] Scripted (run with bash; never touches the live theme): on paper, `--omp`
  writes a config byte-identical to the tracked template; a theme with no `omp`
  block writes nothing and exits 0.

  ```bash
  R=$TERMINAL_REPO_DIR
  TERMINAL_REPO_DIR=$R lua "$R/integrations/claude-code/theme-export.lua" --omp &&
  cmp "$R/shell/oh-my-posh/theme.generated.omp.json" "$R/shell/oh-my-posh/theme.omp.json" &&
  echo "paper: identical ok"   # assumes paper is the active theme
  T=/tmp/omp-noblock; mkdir -p $T/themes; cp "$R"/themes/cyberdream.lua $T/themes/
  echo 'return "cyberdream"' > $T/theme.lua
  TERMINAL_REPO_DIR=$T lua "$R/integrations/claude-code/theme-export.lua" --omp; echo "exit=$? (want 0)"
  test -f $T/shell/oh-my-posh/theme.generated.omp.json && echo "wrote (FAIL)" || echo "no-block: wrote nothing ok"
  rm -rf $T
  ```
- [ ] On paper the prompt is pastel-on-cream — blue path, rosy username, soft-mint
  clean git band (lavender dirty, teal/peach ahead/behind), dark text throughout,
  language diamonds on the right; the `❯` arrow is accent pink and turns orange on
  a failing command (`false`<Enter>, look at the next prompt).
- [ ] `Alt+T` to another theme, run any command → the open shell's prompt recolors
  on its next prompt. A theme with no `omp` block (e.g. cyberdream) falls back to
  the tracked template cleanly — no error, a fine theme-neutral prompt. `Alt+T`
  back to paper → the pastel prompt returns.

## Fish

- [ ] New interactive session starts clean — no errors, no missing-command noise.
- [ ] `ls`/`ll`/`la`/`lt` use eza with icons (plain ls fallback if eza missing).
- [ ] `bat` works (aliased from batcat on Ubuntu).
- [ ] Bare `cd` opens the fuzzy picker rooted at `SMART_CD_ROOT`; `cd /tmp`, `cd ..`, `cd <existing-dir>` behave like builtin cd; with fzf off PATH, `cd` passes through silently.
- [ ] Prompt renders from the repo theme — the `# Defined in` line of `functions fish_prompt` names the same `~/.cache/oh-my-posh/init.<hash>.fish` file that `oh-my-posh init fish --config $TERMINAL_REPO_DIR/shell/oh-my-posh/theme.omp.json | grep -o 'init[^ ]*fish'` prints. (POSH_THEME is not set by current oh-my-posh versions.)
- [ ] OSC 7 cwd inheritance: `cd` somewhere, split a pane — new pane opens there.
- [ ] `theme` lists themes with `*` on the active one (same order as the `Alt+T` cycle); `theme <name>` hot-swaps the terminal (and Claude Code follows within a tick); `theme nope` errors listing valid names; `theme pa<Tab>` completes.
