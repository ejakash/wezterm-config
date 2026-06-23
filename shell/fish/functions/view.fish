# Open a file in the themed wezterm-webview pane (markdown / HTML / PDF), docked
# beside WezTerm. The viewer is a sibling of this repo (../wezterm-webview); this
# wraps its Node CLI, which ensures the render server and signals WezTerm (via the
# `mdview` user-var) to dock the pane. Intentionally shadows /usr/bin/view (vim).
function view -d "Open a file in the themed wezterm-webview pane"
    if not set -q TERMINAL_REPO_DIR
        echo "view: TERMINAL_REPO_DIR is not set (see shell/fish/machine.sample.fish)" >&2
        return 1
    end
    set -l cli $TERMINAL_REPO_DIR/../wezterm-webview/view
    if not test -x $cli
        echo "view: viewer CLI not found at $cli — is ../wezterm-webview present?" >&2
        return 1
    end
    $cli $argv
end
