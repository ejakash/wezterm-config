# List or switch the terminal master theme (themes/*.lua in the wezterm repo).
# `theme` lists with the active one starred; `theme <name>` rewrites the
# gitignored theme.lua selector. WezTerm hot-reloads; Claude Code and its
# statusline follow on the next statusline tick (integrations/claude-code).
function theme -d "List or switch the terminal master theme"
    if not set -q TERMINAL_REPO_DIR
        echo "theme: TERMINAL_REPO_DIR is not set (see shell/fish/machine.sample.fish)" >&2
        return 1
    end
    set -l repo $TERMINAL_REPO_DIR

    set -l names
    for f in $repo/themes/*.lua
        set -a names (basename $f .lua)
    end
    # Byte-wise sort to match the Alt+T cycle order (Lua's table.sort);
    # the locale-aware glob order differs around hyphens.
    set names (printf '%s\n' $names | env LC_ALL=C sort)
    if test (count $names) -eq 0
        echo "theme: no themes found in $repo/themes/" >&2
        return 1
    end

    # Active selection: theme.lua, else the tracked sample (same fallback
    # chain as the wezterm.lua bootstrap).
    set -l active ""
    for sel in $repo/theme.lua $repo/theme.sample.lua
        if test -f $sel
            set active (string match -r --groups-only 'return\s+"([^"]+)"' <$sel)
            break
        end
    end

    if test (count $argv) -eq 0
        for n in $names
            if test "$n" = "$active"
                echo "* $n"
            else
                echo "  $n"
            end
        end
        return 0
    end

    set -l want $argv[1]
    if not contains -- $want $names
        echo "theme: no such theme '$want' — available: $names" >&2
        return 1
    end
    echo "return \"$want\"" >$repo/theme.lua
    # Force the reload: the watcher is unreliable when theme.lua is first
    # created (same workaround the Alt+T binding uses in wezterm.lua).
    touch $repo/wezterm.lua
    echo "theme: $want"
end
