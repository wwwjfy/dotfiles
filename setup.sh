#!/bin/bash

function link_file() {
    if [[ -a ".$1" ]]; then
        rm .$1
    fi
    ln -s dotfiles/$1 .$1
}

set -e

cd $HOME

# self
if [[ ! -a "dotfiles" ]]; then
    git clone --recursive git://github.com/wwwjfy/dotfiles.git
fi

cd dotfiles
git submodule update --init
cd $HOME

if [[ ! -a "bin" ]]; then
    echo "creating ~/bin"
    mkdir bin
fi

if [ ! -h "bin/showmem" ]; then
    rm -f ~/bin/showmem
    echo "linking showmem"
    ln -s ~/dotfiles/bin/showmem ~/bin/showmem
fi

if [ ! -h "bin/showcpu" ]; then
    rm -f ~/bin/showcpu
    echo "linking showcpu"
    ln -s ~/dotfiles/bin/showcpu ~/bin/showcpu
fi

if [ ! -h "bin/stack" ]; then
    rm -f ~/bin/stack
    echo "linking stack"
    ln -s ~/dotfiles/lib/fish/stack/stack ~/bin/stack
fi

# vim
if [[ ! -a ".vim" ]]; then
    git clone --recursive git://github.com/wwwjfy/vimfiles.git .vim
    cd .vim
    git submodule update --init
    cd $HOME
fi

if [[ ! -a ".vimrc" ]]; then
    ln -s .vim/vimrc .vimrc
fi

# configuration files
link_file tmux.conf
link_file gitconfig
link_file gitignore_global
link_file hgrc
link_file hgignore_global
link_file psqlrc

# fish
mkdir -p .config/fish/
if [[ ! -a ".config/fish/config.fish" ]]; then
    ln -s $HOME/dotfiles/fish/config.fish .config/fish/config.fish
fi
if [[ ! -a ".config/fish/functions" ]]; then
    ln -s $HOME/dotfiles/fish/functions .config/fish/functions
fi
if [[ ! -a ".config/fish/completions" ]]; then
    ln -s $HOME/dotfiles/fish/completions .config/fish/completions
fi
if [[ ! -a ".config/ripgreprc" ]]; then
    ln -s $HOME/dotfiles/ripgreprc .config/ripgreprc
fi

if [[ `uname` == "Darwin" ]]; then
    if [[ ! -a "$HOME/.config/karabiner/karabiner.json" ]]; then
        mkdir -p $HOME/.config/karabiner
        cd $HOME/.config/karabiner
        ln -s $HOME/dotfiles/karabiner.json .
        cd $HOME
    fi
    if [[ ! -a "$HOME/.hammerspoon" ]]; then
        ln -s $HOME/dotfiles/hammerspoon .hammerspoon
    fi
fi

if [[ `users` != "vagrant" ]]; then
    if [[ ! -a ".ssh" ]]; then
        mkdir .ssh
        chmod 700 .ssh
    fi
    ssh_pub=AAAAB3NzaC1yc2EAAAADAQABAAABAQDBekVQuNZeXNYbLrs9fgv7q4TguK0jveirhkGLfmAenk0u76g1MqMH7ZNv6K4WXjPItEBFYZtmPi9tDMVwigMIq6qfqiPgBkMAO7ymHLMU04UbWrjxt9Y8ClU2e8Eo2r4wgPkQVbca5rMMClrBvGg6xV5vfo3aJOi/5sXJ9YoJDJ/A0AnvYICaBZ5E61w6eU1+YvPdAxrIqZyxm07d5JDhbilIakhh7f90o5jMbP3vORCq068ockjKgXmwLt9QTOdRhJXt1A5N83Gtmm+d1F4861WpVc4GY2MxX5aUF7j39X/oNIYOxd87l0NXFCbV9aw29ragfezPASbcmBOIK5cd
    cd .ssh
    if ! grep $ssh_pub authorized_keys >/dev/null 2>&1; then
        echo ssh-rsa $ssh_pub tony@tony-mac >> authorized_keys
    fi
fi

if which lsb_release; then
    if [[ $(lsb_release -i) =~ "Ubuntu" ]]; then
        sudo add-apt-repository -y ppa:neovim-ppa/stable
        sudo apt-get update
        sudo apt-get install -y software-properties-common aptitude mercurial mosh fail2ban silversearcher-ag tree htop libevent-dev libncurses5-dev build-essential neovim
        if [[ ! $(grep tony /etc/passwd) =~ "fish" ]]; then
            sudo apt-add-repository -y ppa:fish-shell/release-3
            sudo aptitude update
            sudo aptitude -y install fish
            chsh -s /usr/bin/fish
        fi
        new_passwd=$(uuidgen)
        echo -e "${new_passwd}\n${new_passwd}" | sudo passwd tony
        echo "New password: ${new_passwd}"
    fi
fi
echo
echo "Done."
