# integrations/claude-code — master theme → Claude Code

The wezterm theme (`theme.lua` → `themes/<name>.lua`) recolors Claude Code's
TUI and its statusline. One script does it all:

```
lua $TERMINAL_REPO_DIR/integrations/claude-code/theme-export.lua --bash       # eval-able statusline palette
lua $TERMINAL_REPO_DIR/integrations/claude-code/theme-export.lua --cc-theme   # Claude Code theme JSON to stdout
lua $TERMINAL_REPO_DIR/integrations/claude-code/theme-export.lua --sync       # write ~/.claude/themes/wezterm.json on drift
```

The statusline calls `--bash --sync` every render tick. That keeps its own
colors fresh AND re-syncs the Claude Code theme file, which Claude Code
hot-reloads. So `Alt+T` recolors both within a few seconds. On any failure
the script prints nothing and exits non-zero — callers keep their fallbacks.

**Known limitation (Claude Code side, verified 2026-06-12):** the hot-reload
re-applies most color overrides but not everything — a few TUI elements keep
the previous theme until you run `/theme` and re-select `wezterm`, which
forces the full re-application. There is no programmatic full re-apply, and
the `theme` settings key itself doesn't hot-reload, so a two-file
light/dark variant would not behave better. Tracked upstream as a
documentation gap (claude-code issue #52190).

Needs: `lua` 5.3+ (`sudo apt install lua5.4`) and `$TERMINAL_REPO_DIR`
(set by `~/.config/fish/conf.d/00-machine.fish`; without it the script
falls back to its own location). Claude Code ≥ 2.1.118 for custom themes.

## Install (per machine, one time)

1. **Generate the theme file:**
   `lua $TERMINAL_REPO_DIR/integrations/claude-code/theme-export.lua --sync`
2. **Select it in Claude Code:** run `/theme` and pick `wezterm` (or set
   `"theme": "custom:wezterm"` in `~/.claude/settings.json`).
3. **Patch the statusline** (optional — only if you use the statusline):
   in `~/.claude/statusline-command.sh`, replace the palette block (the
   `BG_L1`…`CLR_CRIT` definitions) with the block below, and make
   `make_gradient_bar` read `GRAD_START_RGB`/`GRAD_END_RGB`/`GRAD_EMPTY`
   instead of its hardcoded RGB values (midpoint of start/end for the
   single-cell fill; `GRAD_EMPTY` also replaces the hardcoded empty color
   in the two `--%` fallback branches).

```bash
# ============================================================
# Palette — defaults: Tokyo Night (fallback when the repo
# exporter is unreachable); the eval overrides them with the
# live master theme from the wezterm repo.
# ============================================================
RST=$'\033[0m'

BG_L1=$'\033[48;2;36;40;59m'       # #24283b
BG_L2=$'\033[48;2;41;46;66m'       # #292e42
FG=$'\033[38;2;169;177;214m'       # #a9b1d6 — main fg (values)
DIM=$'\033[38;2;86;95;137m'        # #565f89 — labels, separators
ACCENT=$'\033[38;2;125;207;255m'   # #7dcfff — dir, model, key values
CLR_OK=$'\033[38;2;158;206;106m'   # #9ece6a green
CLR_WARN=$'\033[38;2;224;175;104m' # #e0af68 amber
CLR_CRIT=$'\033[38;2;247;118;142m' # #f7768e red
GRAD_START_RGB='61;89;161'         # #3d59a1
GRAD_END_RGB='122;162;247'         # #7aa2f7
GRAD_EMPTY=$'\033[38;2;52;59;88m'  # #343b58

if [ -n "$TERMINAL_REPO_DIR" ] && command -v lua >/dev/null 2>&1; then
  eval "$(lua "$TERMINAL_REPO_DIR/integrations/claude-code/theme-export.lua" --bash --sync 2>/dev/null)"
fi
```

And the gradient function becomes:

```bash
# Gradient progress bar: shifts dark-to-bright across filled portion
make_gradient_bar() {
  local pct=$1 width=10
  local gs_r gs_g gs_b ge_r ge_g ge_b
  IFS=';' read -r gs_r gs_g gs_b <<< "$GRAD_START_RGB"
  IFS=';' read -r ge_r ge_g ge_b <<< "$GRAD_END_RGB"
  local filled=0
  if [ -n "$pct" ] && [ "$pct" != "None" ] && [ "$pct" != "" ]; then
    filled=$(awk "BEGIN { v=int($pct * $width / 100 + 0.5); if(v>$width) v=$width; if(v<0) v=0; print v }")
  fi
  local empty=$((width - filled))
  local bar=""
  for ((i=0; i<filled; i++)); do
    if [ "$filled" -le 1 ]; then
      local t_r=$(( (gs_r + ge_r) / 2 )) t_g=$(( (gs_g + ge_g) / 2 )) t_b=$(( (gs_b + ge_b) / 2 ))
    else
      local t_r=$((gs_r + (ge_r - gs_r) * i / (filled-1)))
      local t_g=$((gs_g + (ge_g - gs_g) * i / (filled-1)))
      local t_b=$((gs_b + (ge_b - gs_b) * i / (filled-1)))
    fi
    bar+="\033[38;2;${t_r};${t_g};${t_b}m▰"
  done
  bar+="${GRAD_EMPTY}"
  for ((i=0; i<empty; i++)); do bar+="▱"; done
  printf '%b' "$bar"
}
```

In the two `--%` fallback branches, replace `\033[38;2;52;59;88m` with
`${GRAD_EMPTY}`.

## Portability

- No Claude Code on the machine: nothing runs, nothing is written. WezTerm
  and the fish layer are unaffected.
- Claude Code present but not installed per the steps above: it keeps its
  current theme; the statusline is untouched.
- Patched statusline but repo or `lua` missing: the eval consumes nothing;
  the Tokyo Night defaults above apply.

## Uninstall

Pick another theme in `/theme`; revert the statusline palette block. Delete
`~/.claude/themes/wezterm.json` if you like.
