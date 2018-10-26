if not status -i
    exit
end

. $HOME/dotfiles/lib/fish/z.py/z.fish

# Environment {{{
set -gx PATH /usr/local/sbin /usr/local/bin $PATH
if which gem > /dev/null
    for path in (gem environment gempath | tr ':' '\n')
        if test -d $path/bin
            set -gx PATH $path/bin $PATH
        end
    end
end
if test (uname) = "Darwin"
    set -gx PATH /usr/local/opt/gnu-sed/libexec/gnubin /usr/local/opt/coreutils/libexec/gnubin /usr/local/opt/ruby/bin $PATH
    set -gx GOPATH $HOME/go
end
set -gx PATH $HOME/bin $PATH
set -gx PATH node_modules/.bin $PATH
set -gx NODE_PATH /usr/local/lib/node_modules $NODE_PATH
if test -f /usr/libexec/java_home
    set -gx JAVA_HOME (/usr/libexec/java_home)
    set -gx PATH $JAVA_HOME/bin $PATH
end
set -gx EDITOR vim
set -gx fish_greeting ''
set -gx VIRTUAL_ENV_DISABLE_PROMPT 1
set -gx RIPGREP_CONFIG_PATH $HOME/.config/ripgreprc
eval (dircolors -c $HOME/dotfiles/dircolors.ansi-dark)
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

function readable_time
    set -l tmp $argv[1]
    set -l days (math "$tmp / 60 / 60 / 24")
    set -l hours (math "$tmp / 60 / 60 % 24")
    set -l minutes (math "$tmp / 60 % 60")
    set -l seconds (math "$tmp % 60")
    if test $days -gt 0
        echo -n $days"d "
    end
    if test $hours -gt 0
        echo -n $hours"h "
    end
    if test $minutes -gt 0
        echo -n $minutes"m "
    end
    echo $seconds"s"
end

function fish_prompt
    set last_status $status
    z --add "$PWD" &

    if test $CMD_DURATION
        if test $CMD_DURATION -gt 5000
            echo (set_color 555)"->"(set_color normal) (readable_time (math "$CMD_DURATION / 1000"))
        end
    end
    echo -n ╭─ {$magenta}{$normal}
    echo -n " "
    echo -n {$green}[(date +%H:%M:%S)]{$normal}
    echo -n " "
    echo -n {$cyan}(whoami){$normal} at {$yellow}(hostname -s){$normal}
    echo -n " "
    echo -n {$magenta}➜{$normal}
    echo -n " "
    echo -n $cyan(echo $PWD | sed -e "s|^$HOME|~|")$normal
    git_prompt

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
function l; ls $argv; end
function la; ls -a $argv; end
function ll; ls -lh $argv; end
function lla; ls -lha $argv; end
function cp; command cp -i $argv; end
function mv; command mv -i $argv; end
function grep; command grep --color=auto $argv; end
if test (uname) = "Darwin"
    function find; command gfind $argv; end
end
function v; vim -p $argv; end
function v-; vim -; end
function vf; vim $HOME/.config/fish/config.fish; end
function vv; vim $HOME/.vimrc; end
function ve; . ve/bin/activate.fish; end
function ...; cd ../..; end
function ....; cd ../../..; end
function .....; cd ../../../..; end
function ffind; command ffind -f $argv; end
function top; htop; end
abbr -a t tmux
function em; emacs $argv; end
function e; emacsclient --alternate-editor="" -c $argv; end
function ag; command rg $argv; end
function ag0; command rg --max-depth=1 $argv; end
function ta
    if [ (tmux ls ^/dev/null | wc -l) = "0" ]
        tmux new $argv
    else
        tmux attach $argv
    end
end
# Git {{{
abbr -a g git
abbr -a gc "git commit -v"
abbr -a gca "git commit -v -a"
abbr -a gl "git pull"
abbr -a glg "git log --graph --decorate"
abbr -a glgg "git log --graph --decorate --all"
abbr -a gpf "git push --force-with-lease"
# }}}
# }}}


if test -s $HOME/.config/fish/local.fish
    . $HOME/.config/fish/local.fish
end

uptime
