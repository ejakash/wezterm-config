function cd --description 'smart-cd: cd normally, or fall back to fuzzy picker'
    # Non-interactive shells: pass through to builtin cd.
    if not status is-interactive
        builtin cd $argv
        return
    end

    # Dependencies missing? Pass through to builtin cd.
    if not type -q fzf
        builtin cd $argv
        return
    end
    if not type -q fd; and not type -q fdfind
        builtin cd $argv
        return
    end

    # No args -> open picker
    if test (count $argv) -eq 0
        __smart_cd_pick
        return
    end

    set -l first $argv[1]

    # If first arg looks like a real path (exists, absolute, relative dotted,
    # or tilde-prefixed), pass to builtin cd unchanged.
    if test -d "$first"; or test -f "$first"; \
        or string match -q '.*' -- $first; \
        or string match -q '/*' -- $first; \
        or string match -q '~*' -- $first
        builtin cd $argv
        return
    end

    # Otherwise treat the args as a fuzzy query
    __smart_cd_pick "$argv"
end
