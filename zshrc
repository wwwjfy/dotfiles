# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
# ZSH_THEME="robbyrussell"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git sublime osx vagrant)

export PATH=/Users/tony/bin:/Users/tony/Develop/upstream/go/bin:/usr/local/sbin:/usr/local/bin:/usr/local/Cellar/ruby/1.9.3-p194/bin:/usr/local/share/python:$PATH
source $ZSH/oh-my-zsh.sh
unsetopt correctall
setopt correct

export NODE_PATH=/usr/local/lib/node_modules

PROMPT='╭─%{$fg[magenta]%}  %{$reset_color%}%{$fg[green]%}[%*] %{$fg_no_bold[cyan]%}%n%{$reset_color%}@%{$fg[yellow]%}%m%{$reset_color%} %{$fg_no_bold[magenta]%}➜%{$reset_color%} %{$fg[cyan]%}%~%{$fg_bold[blue]%}$(git_prompt_info)$(hg_prompt_info)%{$fg_bold[blue]%}%{$reset_color%}
╰─%{${fg_bold[white]}%}[%?]%{$reset_color%} $ '
ZSH_THEME_GIT_PROMPT_PREFIX=" git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
DISABLE_UPDATE_PROMPT=true

function hg_prompt_info() {
    echo "$(hg prompt " hg:(%{$fg[red]%}{branch}%{$reset_color%}{status|modified})" 2>/dev/null)"
}

if [[ `uname` == "Darwin" ]]; then
    alias ls="gls --color"
    alias find="gfind"
fi
alias l="ls"
alias la="ls -a"
alias ll="ls -lh"
alias lla="ll -a"
#alias rm="rm -I"
alias cp="cp -i"
alias mv="mv -i"
alias grep="grep --color=auto"
alias vi="vi -p"

uptime
