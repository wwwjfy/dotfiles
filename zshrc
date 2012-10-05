ZSH=$HOME/.oh-my-zsh
DISABLE_UPDATE_PROMPT=true
plugins=(git sublime vagrant)
if [[ `uname` == "Darwin" ]]; then
    . `brew --prefix`/etc/profile.d/z.sh
fi
if [[ `cat /etc/issue 2>/dev/null` =~ "^Ubuntu" ]]; then
    plugins+=command-not-found;
fi

export PATH=$HOME/bin:/usr/local/sbin:/usr/local/bin:/usr/local/Cellar/ruby/1.9.3-p194/bin:/usr/local/share/python:$PATH
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
fi
alias l="ls"
alias la="ls -a"
alias ll="ls -lh"
alias lla="ll -a"
alias cp="cp -i"
alias mv="mv -i"
alias grep="grep --color=auto"
alias vi="vi -p"

uptime
