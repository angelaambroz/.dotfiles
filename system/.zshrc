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
  zsh-vim-mode
)
source $ZSH/oh-my-zsh.sh

# For local Kafka development
export KAFKA_BROKER='localhost:9092'

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
export DEPLOY_ENV="local"

# Update tldr
# echo "Updating tldr."
# tldr --update

# Man entries should be readable
export MANPAGER="col -b | vim -c 'set ft=man ts=8 nomod nolist nonu' -c 'nnoremap i <nop>' -"

# Exports
export HISTCONTROL=ignoredups
export EDITOR=vim

# Pyenv, Vim
eval "$(pyenv init --path)"

# Better cd
eval "$(zoxide init zsh)"

# Better history search
eval "$(mcfly init zsh)"
export MCFLY_KEY_SCHEME=vim

# This is just for exercism 
export PATH="$PATH:/home/angelaambroz/bin"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Something about OSX and multiprocessing that was killing my gunicorn
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES


# Pretty and minimalist
fpath+=$HOME/.zsh/pure
autoload -U promptinit && promptinit
autoload -U compinit && compinit
prompt pure
zstyle :prompt:pure:path color "#af87d7"
zstyle :prompt:pure:prompt:success color "#af87d7"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/aambroz/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/aambroz/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/aambroz/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/aambroz/google-cloud-sdk/completion.zsh.inc'; fi
