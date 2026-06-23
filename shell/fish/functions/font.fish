# List or switch the terminal font (the registry in fonts/*.lua in the wezterm
# repo). `font` lists with the active one starred; `font <name>` rewrites the
# gitignored font.lua selector. WezTerm hot-reloads. Sibling of `theme`.
function font -d "List or switch the terminal font"
    if not set -q TERMINAL_REPO_DIR
        echo "font: TERMINAL_REPO_DIR is not set (see shell/fish/machine.sample.fish)" >&2
        return 1
    end
    set -l repo $TERMINAL_REPO_DIR

    set -l names
    for f in $repo/fonts/*.lua
        set -a names (basename $f .lua)
    end
    # Byte-wise sort to match the Alt+F cycle order (Lua's table.sort).
    set names (printf '%s\n' $names | env LC_ALL=C sort)
    if test (count $names) -eq 0
        echo "font: no fonts found in $repo/fonts/" >&2
        return 1
    end

    # Active selection: font.lua, else the tracked sample (same fallback chain
    # as the wezterm.lua bootstrap).
    set -l active ""
    for sel in $repo/font.lua $repo/font.sample.lua
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
        echo "font: no such font '$want' — available: $names" >&2
        return 1
    end
    echo "return \"$want\"" >$repo/font.lua
    # Force the reload: the watcher is unreliable when font.lua is first created
    # (same workaround the Alt+F binding uses in wezterm.lua).
    touch $repo/wezterm.lua
    echo "font: $want"
end
