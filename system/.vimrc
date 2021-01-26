set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'airblade/vim-gitgutter'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'davidhalter/jedi-vim'
Plugin 'joshdick/onedark.vim'
Plugin 'mattn/emmet-vim'
Plugin 'preservim/nerdtree'
Plugin 'vim-python/python-syntax'
Plugin 'zivyangll/git-blame.vim'
Plugin 'junegunn/vim-emoji'
Plugin 'vim-airline/vim-airline'
Plugin 'tpope/vim-sensible'
Plugin 'tpope/vim-fugitive'

call vundle#end()           
filetype plugin indent on    

" A few more things from https://dougblack.io/words/a-good-vimrc.html
set number
set background=dark
set cursorline
set showmatch
set showcmd

let mapleader = "," " map leader to comma
let g:user_emmet_install_global = 1
let g:python_highlight_all = 1
set completefunc=emoji#complete

" Start NERDTree automatically
" autocmd vimenter * NERDTree
" autocmd StdinReadPre * let s:std_in=1
" autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

"Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
"If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
"(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
if (empty($TMUX))
  if (has("nvim"))
    "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
  "Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
  " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
  if (has("termguicolors"))
    set termguicolors
  endif
endif

colorscheme onedark
