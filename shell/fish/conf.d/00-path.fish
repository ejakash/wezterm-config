# PATH additions (mirrors ~/.bashrc). fish_add_path is idempotent and prepends.
for dir in $HOME/bin $HOME/.local/bin $HOME/.opencode/bin $HOME/.npm-global/bin $HOME/.atuin/bin
    if test -d $dir
        fish_add_path --prepend --path $dir
    end
end
