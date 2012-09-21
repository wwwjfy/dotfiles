#!/bin/bash

set -e

cd $HOME

# self
git clone git://github.com/wwwjfy/dotfiles.git

# vim
git clone git://github.com/wwwjfy/vimfiles.git .vim
cd .vim
git submodule init
git submodule update
cd $HOME
ln -s .vim/vimrc .vimrc

# zsh
cd $HOME
git clone git://github.com/robbyrussell/oh-my-zsh.git .oh-my-zsh
ln -s dotfiles/zshrc .zshrc
ln -s dotfiles/tmux.conf .tmux.conf
ln -s dotfiles/gitconfig .gitconfig
ln -s dotfiles/gitignore_global .gitignore_global

if [[ `users` != "vagrant" ]]; then
    mkdir .ssh -p
    chmod 700 .ssh
    cd .ssh
    echo ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDBekVQuNZeXNYbLrs9fgv7q4TguK0jveirhkGLfmAenk0u76g1MqMH7ZNv6K4WXjPItEBFYZtmPi9tDMVwigMIq6qfqiPgBkMAO7ymHLMU04UbWrjxt9Y8ClU2e8Eo2r4wgPkQVbca5rMMClrBvGg6xV5vfo3aJOi/5sXJ9YoJDJ/A0AnvYICaBZ5E61w6eU1+YvPdAxrIqZyxm07d5JDhbilIakhh7f90o5jMbP3vORCq068ockjKgXmwLt9QTOdRhJXt1A5N83Gtmm+d1F4861WpVc4GY2MxX5aUF7j39X/oNIYOxd87l0NXFCbV9aw29ragfezPASbcmBOIK5cd tony@tony-mac >> authorized_keys
fi
