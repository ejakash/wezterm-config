# Tab-complete font names from the repo's fonts/ registry.
complete -c font -f
complete -c font -a '(for f in $TERMINAL_REPO_DIR/fonts/*.lua; basename $f .lua; end)'
