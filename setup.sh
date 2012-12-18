#!/bin/zsh

function link_file() {
    if [[ ! -a ".$1" ]]; then
        ln -s dotfiles/$1 .$1
    fi
}

set -e

cd $HOME

# self
if [[ ! -a "dotfiles" ]]; then
    git clone git://github.com/wwwjfy/dotfiles.git
    cd dotfiles
    git submodule init
    git submodule update
    cd $HOME
fi

# vim
if [[ ! -a ".vim" ]]; then
    git clone git://github.com/wwwjfy/vimfiles.git .vim
    cd .vim
    git submodule init
    git submodule update
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

if [[ `users` != "vagrant" ]]; then
    if [[ ! -a ".ssh" ]]; then
        mkdir .ssh -p
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
