#!/usr/bin/env fish
# Report which optional tools of this terminal setup are installed.
# Report-only by default — never installs anything. The config degrades
# gracefully without any of these (see shell/fish/ guards).
#
# Row format: label|binaries (any one counts)|install hint
set -l tools \
    "eza|eza|sudo apt install eza            # pretty ls aliases" \
    "fzf|fzf|sudo apt install fzf            # smart-cd fuzzy picker" \
    "fd|fd,fdfind|sudo apt install fd-find   # smart-cd directory walker" \
    "bat|bat,batcat|sudo apt install bat     # syntax-highlighted pager" \
    "oh-my-posh|oh-my-posh|curl -s https://ohmyposh.dev/install.sh | bash -s   # prompt" \
    "atuin|atuin|curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh   # shell history" \
    "lua|lua|sudo apt install lua5.4         # theme exporter (integrations/claude-code; needs the 'lua' name on PATH)" \
    "wslview|wslview|sudo apt install wslu   # open WSL-launched links in the Windows default browser" \
    "node|node|install Node 18+             # markdown-viewer render server (../wezterm-webview)"

set -l missing 0
for row in $tools
    set -l parts (string split -m 2 "|" $row)  # -m 2: install hints may contain pipes
    set -l found ""
    for bin in (string split "," $parts[2])
        if type -q $bin
            set found $bin
            break
        end
    end
    if test -n "$found"
        printf "  ok       %-12s (%s)\n" $parts[1] $found
    else
        printf "  MISSING  %-12s install: %s\n" $parts[1] $parts[3]
        set missing (math $missing + 1)
    end
end

echo
# Custom checks — don't fit binary-on-PATH row format; report-only
set -l host_exe (status dirname)"/../../wezterm-webview/host/bin/Release/net8.0-windows/mdview-host.exe"
if test -f $host_exe
    printf "  ok       %-12s (built)\n" "mdview-host"
else
    printf "  MISSING  %-12s build: dotnet build ../wezterm-webview/host/mdview-host.csproj -c Release  # markdown-viewer pane\n" "mdview-host"
    set missing (math $missing + 1)
end

set -l mdport (set -q MDVIEW_PORT; and echo $MDVIEW_PORT; or echo 8723)
if nc -z 127.0.0.1 $mdport 2>/dev/null
    printf "  ok       %-12s (port %s reachable — server is running)\n" "mdview-server" $mdport
else
    printf "  --       %-12s (port %s not open — normal when viewer is not in use)\n" "mdview-server" $mdport
end

echo
echo "Windows side: WezTerm + a Nerd Font (JetBrains Mono Nerd/Symbols) are required"
echo "for prompt and status-bar glyphs — check manually."
test $missing -eq 0; and echo "All tools present."; or echo "$missing missing (config still works, degraded)."
