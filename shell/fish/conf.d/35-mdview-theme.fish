# Markdown viewer (../wezterm-webview): push the active master theme to the viewer
# as its theme.generated.css, mirroring the oh-my-posh adapter (30-oh-my-posh.fish).
# The viewer is a pure consumer — it reads that file, no lua at render time — so this
# is the producer side: a theme adapter, owned by the terminal like --omp and --sync.
# Regenerates at shell start and again on the next prompt after Alt+T rewrites
# theme.lua, so a theme switch reaches the viewer without touching the Claude Code
# statusline. Best-effort: on any failure the exporter writes nothing and the viewer
# keeps its baked fallback.
if status is-interactive; and set -q TERMINAL_REPO_DIR; and command -q lua
    function __mdview_theme_regen
        lua $TERMINAL_REPO_DIR/integrations/claude-code/theme-export.lua --css-sync 2>/dev/null
    end

    # mtime of theme.lua (the Alt+T selector), or empty when absent.
    function __mdview_theme_mtime
        stat -c %Y $TERMINAL_REPO_DIR/theme.lua 2>/dev/null
    end

    __mdview_theme_regen
    set -g __mdview_theme_stamp (__mdview_theme_mtime)

    # Live refresh: when Alt+T rewrites theme.lua, re-push on the next prompt. The
    # stat is cheap; the exporter only rewrites theme.generated.css if it drifted.
    function __mdview_theme_watch --on-event fish_prompt
        set -l now (__mdview_theme_mtime)
        test "$now" != "$__mdview_theme_stamp"; or return
        set -g __mdview_theme_stamp $now
        __mdview_theme_regen
    end
end
