# Send git branch + CWD to WezTerm on every prompt.
# Active when WEZTERM_* env vars are set (more reliable than TERM_PROGRAM,
# which gets clobbered by tmux/screen/VS Code terminal).
function __wezterm_set_user_vars --on-event fish_prompt
    if not set -q WEZTERM_EXECUTABLE; and not set -q WEZTERM_PANE; and test "$TERM_PROGRAM" != WezTerm
        return
    end

    set -l branch (git branch --show-current 2>/dev/null)
    set -l b64 (printf '%s' "$branch" | base64 -w0)
    printf "\033]1337;SetUserVar=gitbranch=%s\007" $b64

    # OSC 7: report CWD to WezTerm so pane:get_current_working_dir() works.
    # Use "localhost" instead of the real hostname — WezTerm only honours the
    # CWD if the URL host matches its own machine, and WSL's /etc/hostname can
    # differ from the Windows hostname on corporate-imaged PCs.
    printf "\033]7;file://localhost%s\033\\" "$PWD"
end
