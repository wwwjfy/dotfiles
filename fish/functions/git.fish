function gc
    command git commit -v $argv
end

function gca
    command git commit -v -a $argv
end

function gl
    command git pull $argv
end

function glg
    command git log --graph --decorate --all --max-count=5 $argv
end

function glgg
    command git log --graph --decorate --all $argv
end
