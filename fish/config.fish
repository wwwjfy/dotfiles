if not status -i
    exit
end

. $HOME/dotfiles/lib/fish/z.py/z.fish

# Environment {{{
set -p PATH /usr/local/sbin /usr/local/bin
if test (uname) = "Darwin"
    set -p PATH (brew --prefix)/opt/coreutils/libexec/gnubin (brew --prefix)/opt/ruby/bin
    set -gx GOROOT (brew --prefix go)/libexec
    set -gx GOPATH $HOME/go
end
if which gem > /dev/null
    for path in (gem environment gempath | tr ':' '\n')
        if test -d $path/bin
            set -p PATH $path/bin
        end
    end
end
set -p PATH $HOME/bin
set -p PATH node_modules/.bin
set -gx NODE_PATH (brew --prefix)/lib/node_modules $NODE_PATH
if test -f /usr/libexec/java_home
    set -gx JAVA_HOME (/usr/libexec/java_home)
    set -p PATH $JAVA_HOME/bin
end
set -gx EDITOR nvim
set -gx fish_greeting ''
set -gx VIRTUAL_ENV_DISABLE_PROMPT 1
set -gx RIPGREP_CONFIG_PATH $HOME/.config/ripgreprc
set -gx GPG_TTY (tty)
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
    if git rev-parse --show-toplevel >/dev/null 2>&1
        echo -n " git:("{$red}(git rev-parse --abbrev-ref HEAD 2>/dev/null){$normal}")"
        set -l dirty (git status -s -uno --ignored=no 2>/dev/null)
        if test -n "$dirty"
            echo -n " "{$yellow}✗{$normal}
        end
    end
end

function readable_time
    set -l tmp $argv[1]
    set -l days (math --scale 0 "$tmp / 60 / 60 / 24")
    set -l hours (math --scale 0 "$tmp / 60 / 60 % 24")
    set -l minutes (math --scale 0 "$tmp / 60 % 60")
    set -l seconds (math --scale 0 "$tmp % 60")
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
            echo (set_color 555)"->"(set_color normal) (readable_time (math --scale 0 "$CMD_DURATION / 1000"))
        end
    end
    echo -n ╭─
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
    if test (status current-command) = "fish"
        prompt_pwd
    else
        echo (status current-command) "["(basename (prompt_pwd))"]"
    end
end
# }}}

# Aliases {{{
alias l='ls'
alias la='ls -a'
alias ll='ls -lh'
alias lla='ls -lha'
alias cp='cp -i'
alias mv='mv -i'
alias grep='grep --color=auto'
alias v='vim -p'
alias v-='vim -'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias top='htop'
abbr -a t tmux
alias em='emacs'
alias e='emacsclient --alternate-editor="" -c'
alias ag='rg'
alias ag0='rg --max-depth=1'
function ta
    if [ (tmux ls 2>/dev/null | wc -l) = "0" ]
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
