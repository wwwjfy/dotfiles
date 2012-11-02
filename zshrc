ZSH=$HOME/.oh-my-zsh
DISABLE_UPDATE_PROMPT=true
plugins=(git sublime vagrant)
. $HOME/dotfiles/lib/zsh/z/z.sh

if [[ `cat /etc/issue 2>/dev/null` =~ "^Ubuntu" ]]; then
    if [[ -a /etc/zsh_command_not_found ]]; then
        plugins+=command-not-found;
    else
        echo "Please run 'apt-get install command-not-found'"
    fi
fi

export PATH=$HOME/bin:/usr/local/sbin:/usr/local/bin:`brew --prefix ruby`/bin:/usr/local/share/python:$PATH
source $ZSH/oh-my-zsh.sh
unsetopt correctall
setopt correct

export NODE_PATH="/usr/local/lib/node_modules:$NODE_PATH"

# Prompt
VIRTUAL_ENV_DISABLE_PROMPT=1
function virtualenv_info {
    [ $VIRTUAL_ENV ] && echo '('`basename $VIRTUAL_ENV`')'
}
function hg_prompt_info() {
    echo "$(hg prompt " hg:(%{$fg[red]%}{branch}%{$reset_color%}{status|modified})" 2>/dev/null)"
}

PROMPT='╭─%{$fg[magenta]%}  %{$reset_color%}%{$fg[green]%}[%*] %{$fg_no_bold[cyan]%}%n%{$reset_color%} at %{$fg[yellow]%}%m%{$reset_color%} %{$fg_no_bold[magenta]%}➜%{$reset_color%} %{$fg[cyan]%}%~%{$fg_bold[blue]%}$(git_prompt_info)$(hg_prompt_info)%{$fg_bold[blue]%}%{$reset_color%}
╰─%{$fg[yellow]%}$(virtualenv_info)%{$reset_color%}%{${fg_bold[white]}%}[%?]%{$reset_color%} $ '
ZSH_THEME_GIT_PROMPT_PREFIX=" git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"

# Alias
if [[ `uname` == "Darwin" ]]; then
    alias ls="gls --color"
    alias find="gfind"
    export GOROOT=`brew --prefix go`
    export PATH=$GOROOT/bin:$PATH
fi
alias l="ls"
alias la="ls -a"
alias ll="ls -lh"
alias lla="ll -a"
alias cp="cp -i"
alias mv="mv -i"
alias grep="grep --color=auto"
alias vi="vi -p"
alias ....="cd ../../.."
alias .....="cd ../../../.."

uptime
