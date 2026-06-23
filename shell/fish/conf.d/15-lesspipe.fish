# lesspipe: make `less` friendlier for non-text input (archives, PDFs, etc.).
# bash uses `eval "$(SHELL=/bin/sh lesspipe)"` which prints a LESSOPEN export.
# We grab the same string and set LESSOPEN/LESSCLOSE in fish.
if test -x /usr/bin/lesspipe
    for line in (SHELL=/bin/sh /usr/bin/lesspipe)
        # Lines look like:  export LESSOPEN="| /usr/bin/lesspipe %s";
        set -l m (string match -r '^export\s+([A-Z_]+)="?([^";]*)"?;?$' -- $line)
        test (count $m) -eq 3; and set -gx $m[2] $m[3]
    end
end
