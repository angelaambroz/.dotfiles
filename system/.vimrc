set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'davidhalter/jedi-vim'
Plugin 'mattn/emmet-vim'

call vundle#end()           
filetype plugin indent on    

" A few more things from https://dougblack.io/words/a-good-vimrc.html
set number
set background=dark
set cursorline
set showmatch
set showcmd

let g:user_emmet_leader_key=','
let g:user_emmet_install_global = 0
autocmd FileType html,css EmmetInstall
