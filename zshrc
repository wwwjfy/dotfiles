# oh-my-zsh {{{
ZSH=$HOME/.oh-my-zsh
export DISABLE_UPDATE_PROMPT=true
plugins=(git sublime vagrant)
# For Ubuntu {{{
if [[ `cat /etc/issue 2>/dev/null` =~ "^Ubuntu" ]]; then
    if [[ -a /etc/zsh_command_not_found ]]; then
        plugins+=command-not-found;
    else
        echo "Please run 'apt-get install command-not-found'"
    fi
fi
# }}}
source $ZSH/oh-my-zsh.sh
unsetopt correctall
setopt correct
# }}}

# 3rd-party plugins {{{
. $HOME/dotfiles/lib/zsh/z/z.sh
# }}}

# Environment {{{
export PATH=$HOME/bin:/usr/local/sbin:/usr/local/bin:/usr/local/share/python:/usr/local/share/python3:$PATH
export NODE_PATH="/usr/local/lib/node_modules:$NODE_PATH"
export EDITOR="vim"
# }}}

# Prompt {{{
VIRTUAL_ENV_DISABLE_PROMPT=1
function virtualenv_info {
    [ $VIRTUAL_ENV ] && echo '('`basename $VIRTUAL_ENV`')'
}
function hg_prompt_info() {
    echo "$(hg prompt " hg:(%{$fg[red]%}{branch}%{$reset_color%}{status|modified})" 2>/dev/null)"
}

parse_git_dirty() {
  if [[ -n $(git status -s -uno --ignore-submodules=dirty  2> /dev/null) ]]; then
    echo "$ZSH_THEME_GIT_PROMPT_DIRTY"
  else
    echo "$ZSH_THEME_GIT_PROMPT_CLEAN"
  fi
}

PROMPT='╭─%{$fg[magenta]%}  %{$reset_color%}%{$fg[green]%}[%*] %{$fg_no_bold[cyan]%}%n%{$reset_color%} at %{$fg[yellow]%}%m%{$reset_color%} %{$fg_no_bold[magenta]%}➜%{$reset_color%} %{$fg[cyan]%}%~%{$fg_bold[blue]%}$(git_prompt_info)$(hg_prompt_info)%{$fg_bold[blue]%}%{$reset_color%}
╰─%{$fg[yellow]%}$(virtualenv_info)%{$reset_color%}%{${fg_bold[white]}%}[%?]%{$reset_color%} $ '
ZSH_THEME_GIT_PROMPT_PREFIX=" git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
# }}}

# Bindkey {{{
# ctrl-u: clear everything before cursor
bindkey \^U backward-kill-line
# }}}

# Function {{{
function rmme {
    local dir=$(basename $(pwd))
    cd ..
    rm -rf $dir
}
# }}}

# Alias {{{
alias l="ls"
alias la="ls -a"
alias ll="ls -lh"
alias lla="ll -a"
alias cp="cp -i"
alias mv="mv -i"
alias grep="grep --color=auto"
alias vi="vim -p"
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ffind="ffind -f"
alias top=htop
# }}}

# OS Specific {{{
# For OS X {{{
if [[ `uname` == "Darwin" ]]; then
    PATH="$(brew --prefix coreutils)/libexec/gnubin:$(brew --prefix ruby)/bin:$PATH"
    alias ls="ls --color"
    alias find="gfind"
    export GOROOT=`brew --prefix go`
    export PATH=$GOROOT/bin:$PATH
fi
# }}}
# }}}

if [ -e ~/.zshrc.custom ]; then
    source ~/.zshrc.custom
fi

uptime
