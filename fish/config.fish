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
    set -gx PATH /usr/local/opt/coreutils/libexec/gnubin (brew --prefix ruby)/bin $PATH
    set -gx GOPATH /usr/local/opt/go
    set -gx PATH /usr/local/share/npm/bin $GOPATH/bin $PATH
end
set -gx PATH $HOME/bin $PATH
set -gx PATH node_modules/.bin $PATH
set -gx NODE_PATH /usr/local/lib/node_modules $NODE_PATH
if test -f /usr/libexec/java_home
    set -gx JAVA_HOME (/usr/libexec/java_home)
end
set -gx EDITOR vim
set -gx fish_greeting ''
set -gx VIRTUAL_ENV_DISABLE_PROMPT 1
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

function hg_prompt
    hg prompt " hg:($red{branch}$normal{status|modified})" ^/dev/null
end

set github_contrib_file $HOME/.config/fish/github_contribution

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
    z --add "$PWD"

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
    hg_prompt

    # if test (uname) = "Darwin"
    #     if [ -r $github_contrib_file ]
    #         set -l github_contrib (cat $github_contrib_file)
    #         if [ -n $github_contrib ]
    #             echo -n " github:("{$green}{$github_contrib}{$normal}")"
    #         end
    #     end
    # end

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
abbr -a h hg
abbr -a t tmux
function em; emacs $argv; end
function e; emacsclient --alternate-editor="" -c $argv; end
function ag0; ag --depth=0 $argv; end
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

if test (uname) = "Darwin"
    # if test ! -e $github_contrib_file
    #     touch $github_contrib_file
    # end
    # if test (/usr/bin/stat -f "%m" $github_contrib_file) -lt (expr (/bin/date "+%s") - 3600)
    #     fish ~/dotfiles/fish/get_github_contribution wwwjfy $github_contrib_file > /dev/null ^/dev/null &
    # end
    set brew_update_file $HOME/.config/fish/brew_update
    if test ! -e $brew_update_file
        echo (/bin/date "+%s") > $brew_update_file
    end
    if test (/usr/bin/stat -f "%m" $brew_update_file) -lt (expr (/bin/date "+%s") - 3600)
        touch $brew_update_file
        brew update > /dev/null ^/dev/null &
    end
    if test (cat $brew_update_file) -lt (expr (/bin/date "+%s") - 21600)
        echo (/bin/date "+%s") > $brew_update_file
        brew outdated
    end
end

if test -s $HOME/.config/fish/local.fish
    . $HOME/.config/fish/local.fish
end

uptime
