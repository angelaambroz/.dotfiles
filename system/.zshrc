# ZSH stuff
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME=""
HIST_STAMPS="yyyy-mm-dd"
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

echo "HELLO"
cal_mins () {
	echo $1
	echo $2
	# age
	now=`date +%s`
	age=$((($now - $BDATE_SEC)/$SECS_PER_YEAR))
	echo $age

	numerator=`-20.4022 + 0.4472 * $1 + 0.1263 * $WEIGHT + 0.074 * $age`
	cals_per_min=`$numerator/4.184`
	echo $numerator
	echo $cals_per_min

	total_cals=$cals_per_min * $2

	echo $total_cals
}

# Update tldr
# echo "Updating tldr."
# tldr --update

# Man entries should be readable
export MANPAGER="col -b | vim -c 'set ft=man ts=8 nomod nolist nonu' -c 'nnoremap i <nop>' -"

# Exports
export HISTCONTROL=ignoredups
export EDITOR=vim

# Pyenv, Vim
export PATH="/usr/local/bin:/home/angelaambroz/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
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
# zstyle :prompt:pure:path color "#af87d7"
# zstyle :prompt:pure:prompt:success color "#af87d7"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/aambroz/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/aambroz/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/aambroz/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/aambroz/google-cloud-sdk/completion.zsh.inc'; fi

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/aambroz/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/aambroz/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/aambroz/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/aambroz/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# pywal persists on new terminal windows
(\cat ~/.cache/wal/sequences &)

