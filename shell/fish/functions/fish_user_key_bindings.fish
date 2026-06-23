function fish_user_key_bindings
    bind tab __smart_tab
    bind shift-tab complete-and-search
end

function __smart_tab
    if commandline --paging-mode
        commandline -f complete
        return
    end

    set -l before (commandline)
    commandline -f accept-autosuggestion
    if test "$before" != (commandline)
        return
    end

    commandline -f complete
end
