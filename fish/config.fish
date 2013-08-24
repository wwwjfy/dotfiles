if not status -i
    exit
end

. $HOME/dotfiles/lib/fish/z.fish/z.fish

# Environment {{{
set -gx PATH /usr/local/sbin /usr/local/bin $PATH
if which gem > /dev/null
    for path in (gem environment gempath | tr ':' '\n')
        set -gx PATH $path/bin $PATH
    end
end
set -gx PATH /usr/local/share/python /usr/local/share/python3 $PATH
if which npm > /dev/null
    set -gx PATH (npm bin) $PATH
end
if test (uname) = "Darwin"
    set -gx PATH (brew --prefix coreutils)/libexec/gnubin (brew --prefix ruby)/bin $PATH
    set -gx GOPATH (brew --prefix go)
    set -gx PATH $GOPATH/bin $PATH
end
set -gx PATH $HOME/bin $PATH
set -gx NODE_PATH /usr/local/lib/node_modules $NODE_PATH
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
    if git rev-parse --show-toplevel >/dev/null ^&1
        echo -n " git:("{$red}(git rev-parse --abbrev-ref HEAD ^/dev/null){$normal}")"
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

    if set -q CMD_DURATION
        echo (set_color 555)"->"(set_color normal) $CMD_DURATION
    end
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

    set -l scount (stack count)
    if [ $scount != "0" ]
        echo -n " [$scount]" (stack last)
    end

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
        prompt_pwd
    else
        echo $_ "["(basename (prompt_pwd))"]"
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
if test (uname) = "Darwin"
    function find; command gfind $argv; end
end
function v; vim -p $argv; end
function v-; vim -; end
function vf; vim ~/.config/fish/config.fish; end
function ...; cd ../..; end
function ....; cd ../../..; end
function .....; cd ../../../..; end
function ffind; command ffind -f $argv; end
function top; htop; end
make_completion g git
make_completion va vagrant
make_completion t tmux
function e; emacsclient --alternate-editor="" -c $argv; end
function ta; tmux attach $argv; end
# }}}

if test -s $HOME/.config/fish/local.fish
    . $HOME/.config/fish/local.fish
end

uptime
