function make_completion --argument alias command
    eval "function $alias; $command \$argv; end"
    complete -c $alias -xa "(
        set -l cmd (commandline -pc | sed -e 's/^ *\S\+ *//' );
        complete -C\"$command \$cmd\";
    )"
end
