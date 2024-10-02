
# Ubuntu/Debian startup
echo "Debian installs"
echo yes | sudo add-apt-repository ppa:aos1/diff-so-fancy \
&& sudo add-apt-repository ppa:neovim-ppa/stable \
&& sudo apt update
# && sudo apt install python3.7 python3.7-dev python3.7-venv
echo yes | sudo apt install diff-so-fancy \
&& sudo apt install colordiff \
&& sudo apt install xclip
echo yes | sudo npm install -g tldr

# Installing neovim manually-ish
echo yes | curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage \
&& sudo chmod u+x nvim.appimage \
&& sudo rm -rf /opt/nvim \
&& sudo mkdir -p /opt/nvim \
&& sudo mv nvim.appimage /opt/nvim/nvim
echo yes | sudo add-apt-repository universe && sudo apt update
echo yes | sudo apt install libfuse2
export PATH="$PATH:/opt/nvim"


# Shell
echo "Shell is $SHELL"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/plugins/zsh-autosuggestions
git clone https://github.com/softmoth/zsh-vim-mode.git ~/.oh-my-zsh/plugins/zsh-vim-mode
git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"

curl -sS https://webinstall.dev/zoxide | bash
# TODO: This is installing outside of $HOME, let's redirect it
curl -LSfs https://raw.githubusercontent.com/cantino/mcfly/master/ci/install.sh | sudo sh -s -- --git cantino/mcfly

# # Git
# ln -s ~/.dotfiles/git/.global_gitconfig ~/.gitconfig
# ln -s ~/.dotfiles/git/.global_gitignore ~/.gitignore

# # Vim
cp -r ~/.dotfiles/nvim/ ~/.config/

sudo apt-get install ripgrep
sudo apt-get install tig

# # Shell
ln -sf ~/.dotfiles/system/.zshrc ~/.zshrc
source ~/.zshrc

