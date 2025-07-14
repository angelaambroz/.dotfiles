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
sudo apt install -y nala # Pretty
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh # For cargo

######################
# Package Installing #
######################
echo "Installing basic utilities..."
sudo nala install -y \
    diff-so-fancy \
    colordiff \
    xclip \
    libfuse2 \
    ripgrep \
    tig \
    gpg \
    exuberant-ctags
curl -LO https://github.com/ClementTsang/bottom/releases/download/0.10.2/bottom_0.10.2-1_amd64.deb
sudo dpkg -i bottom_0.10.2-1_amd64.deb
cargo install --locked dysk

###################
# NPM packages
# ################
echo "Installing NPM packages..."
sudo npm install -g tldr

###################
# Neovim Install  #
###################
echo "Installing Neovim..."
curl -LO https://github.com/neovim/neovim/releases/download/v0.10.4/nvim-linux-x86_64.appimage
sudo rm -rf /opt/nvim
sudo mkdir -p /opt/nvim
sudo mv nvim-linux-x86_64.appimage /opt/nvim/nvim
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

# Eza
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo apt update
sudo apt install -y eza

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

