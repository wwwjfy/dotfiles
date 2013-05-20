if not status -i
    exit
end

. $HOME/dotfiles/lib/fish/z-fish/z.fish

# Environment {{{
set -gx PATH $HOME/bin /usr/local/sbin /usr/local/bin /usr/local/share/python /usr/local/share/python3 $PATH
set -gx NODE_PATH "/usr/local/lib/node_modules:$NODE_PATH"
set -gx EDITOR vim
set -gx fish_greeting ''
set -gx VIRTUAL_ENV_DISABLE_PROMPT 1
# }}}

# Prompt {{{
set normal (set_color normal)
set magenta (set_color magenta)
set yellow (set_color yellow)
set green (set_color green)
set cyan (set_color cyan)
set white (set_color white)
set red (set_color red)

function git_prompt
    if git symbolic-ref HEAD >/dev/null ^&1
        echo -n " git:("{$red}(git rev-parse --abbrev-ref HEAD){$normal}")"
        set -l dirty (git status -s -uno ^/dev/null)
        if test -n "$dirty"
            echo -n " "{$yellow}✗{$normal}
        end
    end
end

function hg_prompt
    hg prompt " hg:($red{branch}$normal{status|modified})" ^/dev/null
end

function fish_prompt
    set last_status $status
    z --add "$PWD"
    echo -n ╭─ {$magenta}{$normal}
    echo -n " "
    echo -n {$green}[(date +%H:%M:%S)]{$normal}
    echo -n " "
    echo -n {$cyan}(whoami){$normal} at {$yellow}(hostname -s){$normal}
    echo -n " "
    echo -n {$magenta}➜{$normal}
    echo -n " "
    echo -n $cyan"$PWD"$normal | sed -e "s|$HOME|~|"
    git_prompt
    hg_prompt

    echo

    echo -n ╰─

    if [ -n "$VIRTUAL_ENV" ]
        echo -n {$yellow}"("(basename "$VIRTUAL_ENV")")"{$normal}
    end

    if test $last_status -gt 0
        echo -n {$red}"("$last_status")"{$normal}
    end
    echo -n " "
    echo -n \$
    echo -n " "
end

function fish_title
    if test $_ = "fish"
        set pwd (echo $PWD | sed -e "s|$HOME|~|")
        if test (expr length $pwd) -gt 15
            echo $pwd | cut -b (expr length $pwd - 15)-
        else
            echo $pwd
        end
    else
        echo $_
    end
end
# }}}

# Aliases {{{
function l; command ls $argv; end
function la; command ls -a $argv; end
function ll; command ls -lh $argv; end
function lla; command ls -lha $argv; end
function cp; command cp -i $argv; end
function mv; command mv -i $argv; end
function grep; command grep --color=auto $argv; end
function v; vim -p $argv; end
function v-; vim -; end
function ...; cd ../..; end
function ....; cd ../../..; end
function .....; cd ../../../..; end
function ffind; command ffind -f $argv; end
function top; htop; end
function g; git $argv; end
# }}}

# Functions {{{
function take
    mkdir -p $argv[1]
    cd $argv[1]
end

function rmme
    set level 1
    if test (count $argv) -ge 1; and test -n {$argv[1]}
        set level $argv[1]
    end
    for i in (seq (echo $level))
        set dir (basename $PWD)
        cd ..
    end
    echo "About to delete $dir"
    sleep 1
    command rm -rf $dir
end

function make_completion --argument alias command
    complete -c $alias -xa "(
        set -l cmd (commandline -pc | sed -e 's/^ *\S\+ *//' );
        complete -C\"$command \$cmd\";
    )"
end

# }}}

# Completion {{{
if test (uname) = "Darwin"
    set -gx PATH (brew --prefix coreutils)/libexec/gnubin (brew --prefix ruby)/bin $PATH
    function find; command gfind $argv; end
    set -gx GOPATH (brew --prefix go)
    set -gx PATH $GOPATH/bin $PATH
# FIXME: so slow
#     . (brew --prefix)/Library/Contributions/brew_fish_completion.fish
end
# }}}

if test -s $HOME/.config/fish/local.fish
    . $HOME/.config/fish/local.fish
end

uptime
