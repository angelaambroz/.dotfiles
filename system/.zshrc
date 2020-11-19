echo "      ___                                ___           ___           ___           ___                         ___     "
echo "     /\  \                              /\  \         /\  \         /\__\         /\__\                       /\  \    "
echo "     \:\  \       ___                  /::\  \        \:\  \       /:/ _/_       /:/ _/_                     /::\  \   "
echo "      \:\  \     /\__\                /:/\:\  \        \:\  \     /:/ /\  \     /:/ /\__\                   /:/\:\  \  "
echo "  ___ /::\  \   /:/__/               /:/ /::\  \   _____\:\  \   /:/ /::\  \   /:/ /:/ _/_   ___     ___   /:/ /::\  \ "
echo " /\  /:/\:\__\ /::\  \              /:/_/:/\:\__\ /::::::::\__\ /:/__\/\:\__\ /:/_/:/ /\__\ /\  \   /\__\ /:/_/:/\:\__\ "
echo " \:\/:/  \/__/ \/\:\  \__           \:\/:/  \/__/ \:\~~\~~\/__/ \:\  \ /:/  / \:\/:/ /:/  / \:\  \ /:/  / \:\/:/  \/__/ "
echo "  \::/__/         \:\/\__\           \::/__/       \:\  \        \:\  /:/  /   \::/_/:/  /   \:\  /:/  /   \::/__/     "
echo "   \:\  \          \::/  /            \:\  \        \:\  \        \:\/:/  /     \:\/:/  /     \:\/:/  /     \:\  \     "
echo "    \:\__\         /:/  /              \:\__\        \:\__\        \::/  /       \::/  /       \::/  /       \:\__\    "
echo "     \/__/         \/__/                \/__/         \/__/         \/__/         \/__/         \/__/         \/__/    "
date

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

# C compiling stuff (for OpenMP)
# export CC=/usr/bin/clang
# export CXX=/usr/bin/clang++
# export CPPFLAGS="$CPPFLAGS -Xpreprocessor -fopenmp"
# export CFLAGS="$CFLAGS -I/usr/local/opt/libomp/include"
# export CXXFLAGS="$CXXFLAGS -I/usr/local/opt/libomp/include"
# export LDFLAGS="$LDFLAGS -Wl,-rpath,/usr/local/opt/libomp/lib -L/usr/local/opt/libomp/lib -lomp"
# export DYLD_LIBRARY_PATH=/usr/local/opt/libomp/lib

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
echo "Updating tldr."
tldr --update

# Man entries should be readable
export MANPAGER="col -b | vim -c 'set ft=man ts=8 nomod nolist nonu' -c 'nnoremap i <nop>' -"

# Exports
export PATH="$PATH:/Applications/Sublime Text.app/Contents/SharedSupport/bin:$HOME/bin:/usr/local/bin:/Library/Frameworks/Python.framework/Versions/3.6/bin:~/.pyenv/shims:~/.pyenv/bin:$HOME/.rvm/bin:$(brew --prefix qt@5.5)/bin:$HOME/bin/:/usr/local/go/bin"
export HISTCONTROL=ignoredups
export EDITOR='subl'

# Pyenv
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Note-taking
function notes() {
  local TODAY_NOTES=$(date +%Y-%b-%d_%A).md;
  echo $TODAY_NOTES;
  # aliased to my notes folder
  hawaii;
  # aliased to my work name
  if [[ -z $1 ]]; then
    SUBDIR=$WORK
  else
    SUBDIR=$1
  fi

  # if note is empty, create it with a line for the day's date
  if [ ! -f $SUBDIR/$TODAY_NOTES ]; then
    echo "#" $(date "+%A, %b %d %Y") > $SUBDIR/$TODAY_NOTES

  fi

  vi $SUBDIR/$TODAY_NOTES;
}

# Todo.txt in the prompt
# From https://github.com/pengwynn/dotfiles/
# Blog: https://wynnnetherland.com/journal/contextual-todo-list-counts-in-your-zsh-prompt/
todo_count(){
  if $(which todo.sh &> /dev/null);
  then
    num=$(echo $(tls $1 | wc -l));
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

function code_count() {
  find . -name '*.$1' | xargs wc -l
}

# Pretty and minimalist
autoload -U promptinit && promptinit
autoload -U compinit && compinit
prompt pure

# added by Snowflake SnowSQL installer v1.2
export PATH=/Applications/SnowSQL.app/Contents/MacOS:$PATH
