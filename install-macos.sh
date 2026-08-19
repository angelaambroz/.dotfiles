#!/bin/bash
set -e  # Exit on error

echo "Setting up development environment (macOS)..."

###################
# Homebrew        #
###################
echo "Checking for Homebrew..."
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ -d /opt/homebrew/bin ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"   # Apple Silicon
    else
        eval "$(/usr/local/bin/brew shellenv)"      # Intel
    fi
else
    echo "✓ Homebrew already installed"
fi

echo "Updating Homebrew..."
brew update

######################
# Package Installing #
######################
echo "Installing basic utilities..."
# A few apt package names don't exist as-is on Homebrew:
#   fd-find -> fd | trash-cli -> trash | exuberant-ctags -> ctags | gpg -> gnupg
brew install \
    zsh \
    node \
    diff-so-fancy \
    colordiff \
    ripgrep \
    tig \
    gnupg \
    ctags \
    magic-wormhole \
    glow \
    tmux \
    fd \
    trash \
    bottom \
    eza \
    zoxide \
    neovim

# Terminal emulators are GUI .app bundles on macOS, so they're casks, not formulae
brew install --cask alacritty
brew install --cask kitty

# Three Linux-only packages from the original list have no macOS equivalent:
#   xclip     - macOS clipboard access is pbcopy/pbpaste, built in, nothing to install
#   libfuse2  - only needed to run Linux AppImages, not a macOS concept
#   variety   - GTK wallpaper-rotator, no macOS build. Set wallpaper via System
#               Settings, or ask me to script something against
#               ~/.dotfiles/variety/favorites if you want auto-rotation back.

# Rust (check if already installed)
if ! command -v cargo &> /dev/null; then
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
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
if command -v npm &> /dev/null; then
    echo "✓ npm already available"
else
    echo "⚠ npm not found even after 'brew install node' - check your PATH"
fi

if command -v npm &> /dev/null; then
    echo "Installing NPM packages..."
    if ! command -v tldr &> /dev/null; then
        npm install -g tldr
    else
        echo "✓ tldr already installed"
    fi
else
    echo "⚠ Skipping npm package installation - npm not found in current PATH"
fi

###################
# Shell Setup     #
###################
echo "Setting up shell environment..."

# Oh My Zsh (skip if exists) - identical installer on macOS
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "✓ Oh My Zsh already installed"
fi

# ZSH plugins (skip if exist) - plain git clones, nothing OS-specific here
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

###################
# Config Files    #
###################
echo ""
echo "Setting up configuration files..."

# Neovim config
mkdir -p ~/.config
if [ -d ~/.dotfiles/nvim ]; then
    cp -r ~/.dotfiles/nvim ~/.config/
    echo "✓ Neovim config copied"
else
    echo "⚠ Warning: ~/.dotfiles/nvim not found"
fi

# Shell config
ln -sf ~/.dotfiles/system/.zshrc-macos ~/.zshrc
echo "✓ .zshrc symlinked"
echo "  ⚠ heads up: .zshrc still hardcodes Linux paths (linuxbrew, /home/angelaambroz/...)."
echo "    zsh will still start, but those PATH lines point nowhere on this machine."
echo "    Say the word and I'll port that file next."

# Alacritty config
mkdir -p ~/.config/alacritty
if [ ! -f ~/.config/alacritty/alacritty.toml ]; then
    ln -sf $HOME/.dotfiles/system/alacritty.toml ~/.config/alacritty/alacritty.toml
    echo "✓ Alacritty config symlinked"
else
    echo "⚠ Warning: Existing alacritty config found"
fi

# Kitty (per your own comment in the original script, your current terminal of choice)
mkdir -p ~/.config/kitty
if [ ! -f ~/.config/kitty/kitty.conf ]; then
    # NB: the Linux version symlinked to ~/.config/kitty.conf (missing the kitty/
    # subdirectory) while checking for ~/.config/kitty/kitty.conf above it - the
    # symlink target and the existence check never actually agreed. Fixed here.
    ln -sf $HOME/.dotfiles/system/kitty.conf ~/.config/kitty/kitty.conf
    echo "✓ Kitty config symlinked"
else
    echo "⚠ Warning: Existing kitty config found"
fi

# Kitty theme - only link it if the source actually exists. The original line
# ("./kitty-themes/themes/Grape.conf") pointed at a repo that was never vendored
# into ~/.dotfiles, so it would have failed silently-ish on Linux too.
if [ -f ~/.dotfiles/kitty-themes/themes/Grape.conf ]; then
    ln -sf ~/.dotfiles/kitty-themes/themes/Grape.conf ~/.config/kitty/theme.conf
    echo "✓ Kitty theme symlinked"
else
    echo "⚠ Skipping kitty theme - ~/.dotfiles/kitty-themes/themes/Grape.conf not found"
    echo "  (clone https://github.com/dexpota/kitty-themes into ~/.dotfiles/kitty-themes if you want this)"
fi

# Tmux config
ln -sf ~/.dotfiles/system/.tmux.conf ~/.tmux.conf
echo "✓ .tmux.conf symlinked"

# Tmux theme
mkdir -p ~/.config/tmux/plugins/catppuccin
if [ ! -d ~/.config/tmux/plugins/catppuccin/tmux ]; then
    git clone -b v2.1.3 https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin/tmux
    echo "✓ catppuccin tmux theme installed"
else
    echo "✓ catppuccin tmux theme already installed"
fi

# AeroSpace - your Regolith replacement on macOS. Only wired up if you've
# checked the config into the dotfiles repo yet (system/aerospace.toml).
if [ -f ~/.dotfiles/system/aerospace.toml ]; then
    ln -sf ~/.dotfiles/system/aerospace.toml ~/.aerospace.toml
    echo "✓ AeroSpace config symlinked"
else
    echo "⚠ No ~/.dotfiles/system/aerospace.toml yet - add the config we built earlier if you want it version-controlled"
fi

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
echo "To start using your new environment, run:"
echo ""
echo "  exec zsh"
echo ""
echo "═══════════════════════════════════════════════════"
