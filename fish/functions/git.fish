make_completion g git

function gc
    command git commit -v $argv
end
make_completion gc "git commit -v"

function gca
    command git commit -v -a $argv
end
make_completion gca "git commit -v -a"

function gl
    command git pull $argv
end
make_completion gl "git pull"

function glg
    command git log --graph --decorate $argv
end
make_completion glg "git log --graph --decorate"

function glgg
    command git log --graph --decorate --all $argv
end
make_completion glgg "git log --graph --decorate --all"
