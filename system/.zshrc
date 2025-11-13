#====================
# Oh My Zsh Configuration
#====================
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME=""
HIST_STAMPS="yyyy-mm-dd"

# Core plugins
plugins=(
  zsh-syntax-highlighting
  zsh-autosuggestions
  macos
  pip
  brew
  git
  docker
  jira
  pylint
  rand-quote
  sublime
  web-search
  zsh-vim-mode
)
source $ZSH/oh-my-zsh.sh

#====================
# Path & Environment Variables
#====================
export PATH="$PATH:/opt/nvim/:/usr/local/bin:$HOME/bin:/home/linuxbrew/.linuxbrew/bin:$HOME/.local/bin:$HOME/.pyenv/bin"
export HISTCONTROL=ignoredups
export EDITOR=nvim
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES  # Fix for OSX multiprocessing/gunicorn issues

# Make man pages readable in vim
export MANPAGER="col -b | vim -c 'set ft=man ts=8 nomod nolist nonu' -c 'nnoremap i <nop>' -"

#====================
# Source Files & Secrets
#====================
# Load aliases
source "$HOME/.dotfiles/system/.alias"
echo "Loaded non-secrets."

# Load secret files
SECRETS="$HOME/.dotfiles/secrets"
for file in "$SECRETS"/.*
do
  source "$file"
  echo "Loaded $file"
done
echo "Loaded secrets."

cp "$HOME/.dotfiles/system/Xresources" "$HOME/.config/regolith3/"
echo "Moved Xresources to config."

#====================
# Tool Configurations
#====================
# Zoxide - smarter cd command
eval "$(zoxide init zsh)"

# McFly - better history search with vim keybindings
eval "$(mcfly init zsh)"
export MCFLY_KEY_SCHEME=vim

# NVM (Node Version Manager)
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Pyenv configuration
eval "$(pyenv init -)"
eval "$(pyenv init --path)"
eval "$(pyenv virtualenv-init -)"

#====================
# Prompt Configuration
#====================
# Pure prompt setup
fpath+=($HOME/.zsh/pure)
autoload -U promptinit && promptinit
autoload -U compinit && compinit
prompt pure

# Pure prompt colors (currently commented out)
# These use purple/violet shades:
# zstyle :prompt:pure:path color "#af87d7"        # Light purple for directory path
# zstyle :prompt:pure:prompt:success color "#af87d7"  # Light purple for success indicator

#====================
# Additional Tools & Completions
#====================
# Envman configuration
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

# Nix package manager
if [ -e /home/angelaambroz/.nix-profile/etc/profile.d/nix.sh ]; then 
    . /home/angelaambroz/.nix-profile/etc/profile.d/nix.sh
fi

# Clyde completion
_clyde() {
  eval $(env COMMANDLINE="${words[1,$CURRENT]}" _CLYDE_COMPLETE=complete-zsh  clyde)
}
if [[ "$(basename -- ${(%):-%x})" != "_clyde" ]]; then
  compdef _clyde clyde
fi

fpath+=${ZDOTDIR:-~}/.zsh_functions

#====================
# Application Configs
#====================
# Alacritty configuration setup
mkdir -p ~/.config/alacritty
if [ ! -f ~/.config/alacritty/alacritty.toml ]; then
    ln -s $HOME/.dotfiles/system/alacritty.toml ~/.config/alacritty/alacritty.toml
fi

export PATH="/home/angelaambroz/Documents/work/discord/.local/bin:$PATH"
#compdef clyde
_clyde() {
  eval "$(_CLYDE_COMPLETE=zsh_source clyde)"
}
if [[ "$(basename -- ${(%):-%x})" != "_clyde" ]]; then
  compdef _clyde clyde
fi
. "/home/angelaambroz/.deno/env"
#compdef clyde
_clyde() {
  eval "$(_CLYDE_COMPLETE=zsh_source clyde)"
}
if [[ "$(basename -- ${(%):-%x})" != "_clyde" ]]; then
  compdef _clyde clyde
fi

source /home/angelaambroz/.nix-profile/etc/profile.d/nix.sh
