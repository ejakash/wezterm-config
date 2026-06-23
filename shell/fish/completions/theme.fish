# Tab-complete theme names from the repo's themes/ directory.
complete -c theme -f
complete -c theme -a '(for f in $TERMINAL_REPO_DIR/themes/*.lua; basename $f .lua; end)'
