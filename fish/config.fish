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
        set cwd (echo $PWD | sed -e "s|$HOME|~|")
        if test (expr length $cwd) -eq 1
            echo $cwd
        else
            set path (basename $cwd)
            set cwd (dirname $cwd)
            while test (expr length $cwd) -ne 1
                set path (basename $cwd | cut -b1)/$path
                set cwd (dirname $cwd)
            end
            echo $cwd/$path
        end
        # if test (expr length $pwd) -gt 15
        #     echo $pwd | cut -b (expr length $pwd - 15)-
        # else
        #     echo $pwd
        # end
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
function vf; vim ~/.config/fish/config.fish; end
function ...; cd ../..; end
function ....; cd ../../..; end
function .....; cd ../../../..; end
function ffind; command ffind -f $argv; end
function top; htop; end
function g; git $argv; end
# }}}

# Completion {{{
if test (uname) = "Darwin"
    set -gx PATH (brew --prefix coreutils)/libexec/gnubin (brew --prefix ruby)/bin $PATH
    function find; command gfind $argv; end
    set -gx GOPATH (brew --prefix go)
    set -gx PATH $GOPATH/bin $PATH
end
# }}}

if test -s $HOME/.config/fish/local.fish
    . $HOME/.config/fish/local.fish
end

uptime
