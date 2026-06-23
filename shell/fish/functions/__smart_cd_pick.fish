function __smart_cd_pick --description 'fzf+fd directory picker rooted at $SMART_CD_ROOT'
    set -l root $SMART_CD_ROOT
    test -n "$root"; or set root $HOME

    set -l fd_cmd
    if type -q fd
        set fd_cmd fd
    else if type -q fdfind
        set fd_cmd fdfind
    else
        echo "smart-cd: fd not installed" >&2
        return 1
    end

    set -l query "$argv"

    set -l target ($fd_cmd . $root \
        --type d --max-depth 5 --hidden \
        --exclude .git --exclude node_modules --exclude bin --exclude obj \
        --exclude .cache --exclude .local --exclude .npm --exclude .cargo \
        --exclude .venv --exclude venv --exclude dist --exclude build \
        --exclude target --exclude Downloads --exclude Pictures \
        --exclude Videos --exclude Music \
        2>/dev/null \
        | string replace -- "$root/" "" \
        | fzf --height 50% --reverse --prompt="cd> " --query=$query)

    if test -n "$target"
        builtin cd "$root/$target"
    end
end
