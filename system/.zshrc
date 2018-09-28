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

# Update tldr
echo "Updating tldr."
tldr --update

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

# Todo.txt in the prompt
# From https://github.com/pengwynn/dotfiles/
todo_count(){
  if $(which todo.sh &> /dev/null);
  then
    num=$(echo $(todo.sh ls $1 | wc -l));
    let todos=num-2;
    if [ $todos != 0 ]; then
      echo "$todos";
    else
      echo "";
    fi
  else
    echo "";
  fi
}

function todo_prompt() {
  local COUNT=$(todo_count $1);
  if [[ -z $COUNT ]]; then 
    COUNT=0;
  fi
  if [ $COUNT != 0 ]; then
    echo "$1: $COUNT";
  else
    echo "";
  fi
}

function notes_count() {
  if [[ -z $1 ]]; then
    local NOTES_PATTERN="TODO|FIXME|HACK";
  else
    local NOTES_PATTERN=$1;
  fi
  grep -ERn "\b($NOTES_PATTERN)\b" {*.md,*.py} 2>/dev/null | wc -l | sed 's/ //g'
}

function notes_prompt() {
  local COUNT=$(notes_count $1);
  if [ $COUNT != 0 ]; then
    echo "$1: $COUNT";
  else
    echo "";
  fi
}

# Pretty and minimalist
autoload -U promptinit; promptinit
prompt pure

# On prompt load, change the right-hand side prompt (context!)
precmd() {
  export RPROMPT="$(notes_prompt TODO) %{$fg_bold[yellow]%}$(notes_prompt HACK)%{$reset_color%} %{$fg_bold[red]%}$(notes_prompt FIXME)%{$reset_color%} %{$fg_bold[white]%}$(todo_prompt +next)%{$reset_color%}"  
}

