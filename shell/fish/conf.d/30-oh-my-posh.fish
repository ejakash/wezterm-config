# Prompt: oh-my-posh, recolored from the repo's master theme when
# TERMINAL_REPO_DIR is set (00-machine.fish). The exporter's --omp mode
# regenerates theme.generated.omp.json from the active theme; we prefer it,
# fall back to the tracked template, then the legacy ~/.config copy. Open
# shells follow Alt+T theme changes on their next prompt via the mtime watch.
if status is-interactive; and test -x $HOME/.local/bin/oh-my-posh
    set -g __omp_bin $HOME/.local/bin/oh-my-posh

    # The config to source: generated if present, else tracked template, else legacy.
    function __omp_config_path
        if set -q TERMINAL_REPO_DIR
            set -l gen $TERMINAL_REPO_DIR/shell/oh-my-posh/theme.generated.omp.json
            set -l tmpl $TERMINAL_REPO_DIR/shell/oh-my-posh/theme.omp.json
            if test -f $gen
                echo $gen
                return
            else if test -f $tmpl
                echo $tmpl
                return
            end
        end
        echo $HOME/.config/oh-my-posh/theme.omp.json
    end

    # Regenerate the colored config from the active theme. Best-effort: on any
    # failure the exporter writes nothing and the fallback stays in place.
    function __omp_regen
        if set -q TERMINAL_REPO_DIR; and command -q lua
            lua $TERMINAL_REPO_DIR/integrations/claude-code/theme-export.lua --omp 2>/dev/null
        end
    end

    # mtime of theme.lua (the Alt+T selector), or empty when absent.
    function __omp_theme_mtime
        set -q TERMINAL_REPO_DIR; or return
        stat -c %Y $TERMINAL_REPO_DIR/theme.lua 2>/dev/null
    end

    __omp_regen
    $__omp_bin init fish --config (__omp_config_path) | source
    set -g __omp_stamp (__omp_theme_mtime)

    # Live refresh: when Alt+T rewrites theme.lua, regenerate and re-source on
    # the next prompt. The stat is cheap; the reinit runs only after a change.
    function __omp_watch --on-event fish_prompt
        set -l now (__omp_theme_mtime)
        test "$now" != "$__omp_stamp"; or return
        set -g __omp_stamp $now
        __omp_regen
        $__omp_bin init fish --config (__omp_config_path) | source
    end
end
