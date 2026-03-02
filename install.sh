#!/bin/bash
set -e  # Exit on error

echo "Setting up development environment..."

###################
# Package Sources #
###################
echo "Adding package repositories..."
sudo add-apt-repository -y ppa:aos1/diff-so-fancy
sudo add-apt-repository -y universe
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
sudo apt update

######################
# Package Installing #
######################
echo "Installing basic utilities..."
sudo apt install -y nala

sudo nala install -y \
    zsh \
    diff-so-fancy \
    colordiff \
    xclip \
    libfuse2 \
    ripgrep \
    tig \
    gpg \
    exuberant-ctags \
    magic-wormhole \
    glow \
    tmux \
    variety \
    fd-find \
    trash-cli \

# Bottom
if ! command -v btm &> /dev/null; then
    echo "Installing bottom..."
    curl -LO https://github.com/ClementTsang/bottom/releases/download/0.10.2/bottom_0.10.2-1_amd64.deb
    sudo dpkg -i bottom_0.10.2-1_amd64.deb
    rm bottom_0.10.2-1_amd64.deb
else
    echo "✓ bottom already installed"
fi

# Rust (check if already installed)
if ! command -v cargo &> /dev/null; then
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
#    source "$HOME/.cargo/env"
else
    echo "✓ Rust already installed"
fi

# Dysk
if ! command -v dysk &> /dev/null; then
    echo "Installing dysk..."
#    cargo install --locked dysk
else
    echo "✓ dysk already installed"
fi

###################
# Node/NPM        #
###################
# Check if npm is available (might be from Nix or other sources)
if command -v npm &> /dev/null; then
    echo "✓ npm already available"
elif command -v node &> /dev/null; then
    echo "⚠ Node.js found but npm missing - this is unusual"
    echo "  npm should be available in your zsh environment"
else
    echo "Installing Node.js via NodeSource..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt install -y nodejs
fi

# Only try to install npm packages if npm is available
if command -v npm &> /dev/null; then
    echo "Installing NPM packages..."
    # Check if tldr is already installed
    if ! command -v tldr &> /dev/null; then
        sudo npm install -g tldr
    else
        echo "✓ tldr already installed"
    fi
else
    echo "⚠ Skipping npm package installation - npm not found in current PATH"
    echo "  npm may be available after starting zsh (from Nix or other sources)"
fi

###################
# Neovim Install  #
###################
if [ ! -f /opt/nvim/nvim ]; then
    echo "Installing Neovim..."
    curl -LO https://github.com/neovim/neovim/releases/download/v0.11.5/nvim-linux-x86_64.appimage
    sudo rm -rf /opt/nvim
    sudo mkdir -p /opt/nvim
    sudo mv nvim-linux-x86_64.appimage /opt/nvim/nvim
    sudo chmod u+x /opt/nvim/nvim
else
    echo "✓ Neovim already installed"
fi

###################
# Shell Setup     #
###################
echo "Setting up shell environment..."

# Oh My Zsh (skip if exists)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "✓ Oh My Zsh already installed"
fi

# ZSH plugins (skip if exist)
echo "Installing zsh plugins..."
[ ! -d ~/.oh-my-zsh/plugins/zsh-syntax-highlighting ] && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/plugins/zsh-syntax-highlighting || \
    echo "✓ zsh-syntax-highlighting already installed"

[ ! -d ~/.oh-my-zsh/plugins/zsh-autosuggestions ] && \
    git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/plugins/zsh-autosuggestions || \
    echo "✓ zsh-autosuggestions already installed"

[ ! -d ~/.oh-my-zsh/plugins/zsh-vim-mode ] && \
    git clone https://github.com/softmoth/zsh-vim-mode.git ~/.oh-my-zsh/plugins/zsh-vim-mode || \
    echo "✓ zsh-vim-mode already installed"

[ ! -d "$HOME/.zsh/pure" ] && \
    git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure" || \
    echo "✓ pure prompt already installed"

# Additional shell tools
if ! command -v zoxide &> /dev/null; then
    echo "Installing zoxide..."
    curl -sS https://webinstall.dev/zoxide | bash
else
    echo "✓ zoxide already installed"
fi

if ! command -v mcfly &> /dev/null; then
    echo "Installing mcfly..."
    curl -LSfs https://raw.githubusercontent.com/cantino/mcfly/master/ci/install.sh | sh -s -- --git cantino/mcfly --force
else
    echo "✓ mcfly already installed"
fi

# Eza
if ! command -v eza &> /dev/null; then
    echo "Installing eza..."
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --yes --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt update
    sudo apt install -y eza
else
    echo "✓ eza already installed"
fi

###################
# Config Files    #
###################
echo ""
echo "Setting up configuration files..."

# Neovim config
mkdir -p ~/.config
if [ -d ~/.dotfiles/nvim ]; then
    cp -r ~/.dotfiles/nvim/ ~/.config/
    echo "✓ Neovim config copied"
else
    echo "⚠ Warning: ~/.dotfiles/nvim not found"
fi

# Shell config
ln -sf ~/.dotfiles/system/.zshrc ~/.zshrc
echo "✓ .zshrc symlinked"

# Alacritty config
mkdir -p ~/.config/alacritty
if [ ! -f ~/.config/alacritty/alacritty.toml ]; then
    ln -sf $HOME/.dotfiles/system/alacritty.toml ~/.config/alacritty/alacritty.toml
    echo "✓ Alacritty config symlinked"
else
    echo "⚠ Warning: Existing alacritty config found"
fi

# Actually, I think I'm switching to kitty
mkdir -p ~/.config/kitty
if [ ! -f ~/.config/kitty/kitty.conf ]; then
    ln -sf $HOME/.dotfiles/system/kitty.conf ~/.config/kitty.conf
    echo "✓ Kitty config symlinked"
else
    echo "⚠ Warning: Existing kitty config found"
fi

# need to clean this up - e.g. git clone the repo in ~/.config, etc
ln -s ./kitty-themes/themes/Grape.conf ~/.config/kitty/theme.conf

# Regolith config (if directory exists)
if [ -d ~/.config/regolith3 ]; then
    cp ~/.dotfiles/system/Xresources ~/.config/regolith3/
    echo "✓ Xresources copied to regolith3"
fi

# Tmux config
ln -sf ~/.dotfiles/system/.tmux.conf ~/.tmux.conf
echo "✓ .tmux.conf symlinked"

# Tmux theme
mkdir -p ~/.config/tmux/plugins/catppuccin
git clone -b v2.1.3 https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin/tmux
echo "✓ catppuccin tmux theme installed"

###################
# Verification    #
###################
echo ""
echo "Verifying dotfiles structure..."
[ -f ~/.dotfiles/system/.alias ] && echo "✓ Aliases file found"
[ -f ~/.dotfiles/system/.zshrc ] && echo "✓ .zshrc file found"
[ -d ~/.dotfiles/secrets ] && echo "✓ Secrets directory found" || echo "⚠ Secrets directory not found"

if [ -d ~/.dotfiles/secrets ]; then
    SECRETS_COUNT=$(find ~/.dotfiles/secrets -type f -name ".*" 2>/dev/null | wc -l)
    echo "✓ Found $SECRETS_COUNT secret files"
fi

###################
# Completion      #
###################
echo ""
echo "═══════════════════════════════════════════════════"
echo "  Installation complete! 🎉"
echo "═══════════════════════════════════════════════════"
echo ""
echo "Your aliases, API keys, and environment will be"
echo "loaded automatically when you start zsh."
echo ""

# Give specific next steps based on npm availability
if ! command -v npm &> /dev/null; then
    echo "Note: npm was not found in the current PATH."
    echo "If you have npm via Nix or another source,"
    echo "you can install tldr after starting zsh with:"
    echo ""
    echo "  npm install -g tldr"
    echo ""
fi

echo "To start using your new environment, run:"
echo ""
echo "  exec zsh"
echo ""
echo "═══════════════════════════════════════════════════"
