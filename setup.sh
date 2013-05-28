#!/bin/zsh

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

if [ ! -h "bin/ffind" ]; then
    rm -f ~/bin/ffind
    echo "linking ffind"
    ln -s ~/dotfiles/lib/friendly-find/ffind ~/bin/ffind
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

# zsh
if [[ ! -a ".oh-my-zsh" ]]; then
    git clone git://github.com/robbyrussell/oh-my-zsh.git .oh-my-zsh
fi
link_file zshrc
link_file tmux.conf
link_file gitconfig
link_file gitignore_global
link_file hgrc
link_file hgignore_global

# fish
ln -s $HOME/dotfiles/fish/config.fish .config/fish/config.fish
ln -s $HOME/dotfiles/fish/functions .config/fish/functions
ln -s $HOME/dotfiles/fish/completions .config/fish/completions

if [[ `uname` == "Darwin" ]]; then
    KeyRemap4MacBookPath="$HOME/Library/Application Support/KeyRemap4MacBook"
    if [[ ! -a "$KeyRemap4MacBookPath" ]]; then
        mkdir -p "$KeyRemap4MacBookPath"
    fi
    cd $KeyRemap4MacBookPath
    if [[ ! -a "private.xml" ]]; then
        ln -s $HOME/dotfiles/KeyRemap4MacBook/private.xml .
    fi
    cd $HOME
    link_file slate
fi

if [[ `users` != "vagrant" ]]; then
    if [[ ! -a ".ssh" ]]; then
        mkdir .ssh
        chmod 700 .ssh
    fi
    ssh_pub=AAAAB3NzaC1yc2EAAAADAQABAAABAQDBekVQuNZeXNYbLrs9fgv7q4TguK0jveirhkGLfmAenk0u76g1MqMH7ZNv6K4WXjPItEBFYZtmPi9tDMVwigMIq6qfqiPgBkMAO7ymHLMU04UbWrjxt9Y8ClU2e8Eo2r4wgPkQVbca5rMMClrBvGg6xV5vfo3aJOi/5sXJ9YoJDJ/A0AnvYICaBZ5E61w6eU1+YvPdAxrIqZyxm07d5JDhbilIakhh7f90o5jMbP3vORCq068ockjKgXmwLt9QTOdRhJXt1A5N83Gtmm+d1F4861WpVc4GY2MxX5aUF7j39X/oNIYOxd87l0NXFCbV9aw29ragfezPASbcmBOIK5cd
    cd .ssh
    if ! grep $ssh_pub authorized_keys >/dev/null 2>&1; then
        echo ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDBekVQuNZeXNYbLrs9fgv7q4TguK0jveirhkGLfmAenk0u76g1MqMH7ZNv6K4WXjPItEBFYZtmPi9tDMVwigMIq6qfqiPgBkMAO7ymHLMU04UbWrjxt9Y8ClU2e8Eo2r4wgPkQVbca5rMMClrBvGg6xV5vfo3aJOi/5sXJ9YoJDJ/A0AnvYICaBZ5E61w6eU1+YvPdAxrIqZyxm07d5JDhbilIakhh7f90o5jMbP3vORCq068ockjKgXmwLt9QTOdRhJXt1A5N83Gtmm+d1F4861WpVc4GY2MxX5aUF7j39X/oNIYOxd87l0NXFCbV9aw29ragfezPASbcmBOIK5cd tony@tony-mac >> authorized_keys
    fi
fi
echo
echo "Done."
