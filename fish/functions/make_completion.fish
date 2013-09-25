function make_completion --argument alias command
    eval "function $alias; $command \$argv; end"
    complete -c $alias -xa "(
        set -l cmd (commandline -pc | sed -e 's/^ *\S\+ *//' -e 's/\\\\\\\\\\\\(.\\\\)/\\\\1/' )
        complete -C\"$command \$cmd\"
    )"
end
