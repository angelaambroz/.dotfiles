#!/bin/bash

echo "Setting up development environment..."

###################
# Package Sources #
###################
echo "Adding package repositories..."
sudo add-apt-repository -y ppa:aos1/diff-so-fancy
sudo add-apt-repository -y ppa:neovim-ppa/stable
sudo add-apt-repository -y universe
sudo apt update

######################
# Package Installing #
######################
echo "Installing basic utilities..."
sudo apt install -y \
    diff-so-fancy \
    colordiff \
    xclip \
    libfuse2 \
    ripgrep \
    tig

# NPM packages
echo "Installing NPM packages..."
sudo npm install -g tldr

###################
# Neovim Install  #
###################
echo "Installing Neovim..."
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
sudo rm -rf /opt/nvim
sudo mkdir -p /opt/nvim
sudo mv nvim.appimage /opt/nvim/nvim
sudo chmod u+x /opt/nvim/nvim
export PATH="$PATH:/opt/nvim"

###################
# Shell Setup     #
###################
echo "Setting up shell environment..."
# Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# ZSH plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/plugins/zsh-autosuggestions
git clone https://github.com/softmoth/zsh-vim-mode.git ~/.oh-my-zsh/plugins/zsh-vim-mode
git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"

# Additional shell tools
curl -sS https://webinstall.dev/zoxide | bash
curl -LSfs https://raw.githubusercontent.com/cantino/mcfly/master/ci/install.sh | sudo sh -s -- --git cantino/mcfly

###################
# Config Files    #
###################
echo "Setting up configuration files..."
# Neovim config
cp -r ~/.dotfiles/nvim/ ~/.config/

# Shell config
ln -sf ~/.dotfiles/system/.zshrc ~/.zshrc
source ~/.zshrc

echo "Installation complete!"

