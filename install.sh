# Symlinking the relevant dotiles

# Ubuntu/Debian startup
echo "Debian installs"
echo yes | sudo add-apt-repository ppa:aos1/diff-so-fancy
echo yes | sudo apt update
echo yes | sudo apt upgrade
echo yes | sudo apt install python3.7 python3.7-dev python3.7-venv
echo yes | sudo apt install diff-so-fancy
echo yes | sudo apt install colordiff
echo yes | sudo npm install -g tldr
git clone https://github.com/universal-ctags/ctags.git
cd ctags
echo yes | ./autogen.sh
echo yes | ./configure
echo yes | make
sudo make install # may require extra privileges depending on where to install
export PATH=$PATH:/home/discord/.dotfiles/ctags
cd ~

echo "Installing dotfiles in $HOME"

# If we're not in .dotfiles, move there
mv $(pwd) .dotfiles

# Shell
echo "Shell is $SHELL"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/plugins/zsh-autosuggestions
git clone https://github.com/softmoth/zsh-vim-mode.git ~/.oh-my-zsh/plugins/zsh-vim-mode
git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"

curl -sS https://webinstall.dev/zoxide | bash
curl -LSfs https://raw.githubusercontent.com/cantino/mcfly/master/ci/install.sh | sudo sh -s -- --git cantino/mcfly

# Git
ln -s ~/.dotfiles/git/.global_gitconfig ~/.gitconfig
ln -s ~/.dotfiles/git/.global_gitignore ~/.gitignore

# Vim
cp -r ~/.dotfiles/nvim/ ~/.config/nvim/
ln -s ~/.dotfiles/system/.vimrc ~/.vimrc
ln -s ~/.dotfiles/system/.vimspector.json ~/.vimspector.json

# Neovim
sudo add-apt-repository ppa:neovim-ppa/unstable
echo yes | sudo apt-get update
echo yes | sudo apt-get install neovim

# Shell
ln -sf ~/.dotfiles/system/.zshrc ~/.zshrc
source ~/.zshrc

