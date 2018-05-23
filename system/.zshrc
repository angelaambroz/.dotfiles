# ZSH stuff
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME=""
HIST_STAMPS="yyyy-mm-dd"
plugins=(
  zsh-syntax-highlighting
  zsh-autosuggestions
  osx
  pip
  brew
  git
  docker
  jira
  pylint
  rand-quote
  sublime
  tmux
  web-search
)
source $ZSH/oh-my-zsh.sh

# Load all my secrets
SECRETS="$HOME/.dotfiles/secrets"
for file in "$SECRETS"/.*
do
    source "$file"
done
echo "Loaded secrets."

# Load non-secrets
source "$HOME/.dotfiles/system/.alias"
echo "Loaded non-secrets."

# Exports
export PATH="$PATH:$HOME/bin:/usr/local/bin:/Library/Frameworks/Python.framework/Versions/3.6/bin:~/.pyenv/shims:~/.pyenv/bin:$HOME/.rvm/bin:$(brew --prefix qt@5.5)/bin:$HOME/bin/"
export HISTCONTROL=ignoredups
export EDITOR='subl'

# Pyenv
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" 

# Pretty and minimalist
autoload -U promptinit; promptinit
prompt pure
