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

# Load non-secrets
source "$HOME/.dotfiles/system/.alias"
echo "Loaded non-secrets."

# Load all my secrets
SECRETS="$HOME/.dotfiles/secrets"
for file in "$SECRETS"/.*
do
   source "$file"
done
echo "Loaded secrets."

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

# Vim
export PATH="$PATH:/usr/local/bin:$HOME/bin:/home/linuxbrew/.linuxbrew/bin:$HOME/.local/bin"


# Better cd
eval "$(zoxide init zsh)"

# Better history search
eval "$(mcfly init zsh)"
export MCFLY_KEY_SCHEME=vim

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

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

# pywal persists on new terminal windows
# (\cat ~/.cache/wal/sequences &)

if [ -e /home/angelaambroz/.nix-profile/etc/profile.d/nix.sh ]; then . /home/angelaambroz/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer

# Pyenv at home, workon at work
export PATH="$PATH:/.pyenv/bin"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
eval "$(pyenv init --path)"
#compdef clyde
_clyde() {
  eval $(env COMMANDLINE="${words[1,$CURRENT]}" _CLYDE_COMPLETE=complete-zsh  clyde)
}
if [[ "$(basename -- ${(%):-%x})" != "_clyde" ]]; then
  compdef _clyde clyde
fi
