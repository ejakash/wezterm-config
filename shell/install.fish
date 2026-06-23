#!/usr/bin/env fish
# Symlink this repo's tracked fish snippets/functions into ~/.config/fish/.
# Idempotent: re-running refreshes links. Pre-existing real files are moved
# aside to <name>.pre-repo, never overwritten. machine.sample.fish is NOT
# linked — copy it to ~/.config/fish/conf.d/00-machine.fish yourself.
set -l repo_shell (dirname (realpath (status filename)))

for sub in conf.d functions completions
    mkdir -p $HOME/.config/fish/$sub
    for src in $repo_shell/fish/$sub/*.fish
        set -l dest $HOME/.config/fish/$sub/(basename $src)
        if test -L $dest
            ln -sf $src $dest
        else if test -e $dest
            mv $dest $dest.pre-repo
            echo "moved aside: $dest -> $dest.pre-repo"
            ln -s $src $dest
        else
            ln -s $src $dest
        end
        echo "linked: $dest"
    end
end

if not test -e $HOME/.config/fish/conf.d/00-machine.fish
    echo
    echo "NOTE: no 00-machine.fish — copy $repo_shell/fish/machine.sample.fish"
    echo "      to ~/.config/fish/conf.d/00-machine.fish and edit."
end
