" A lot of stuff from https://dougblack.io/words/a-good-vimrc.html

syntax enable " syntax highlighting
set ruler " LR corner rows, cols
set number " gutter number
set background=dark " duh
colorscheme molokai " duh
set tabstop=4       " number of visual spaces per TAB
set softtabstop=4   " number of spaces in tab when editing
set expandtab       " tabs are spaces
set cursorline          " highlight current line
filetype indent on      " load filetype-specific indent files
set wildmenu            " visual autocomplete for command menu
set lazyredraw          " redraw only when we need to.
set showmatch           " highlight matching [{()}]
set incsearch           " search as characters are entered
set hlsearch            " highlight matches
nnoremap <leader><space> :nohlsearch<CR>

" jk is escape
inoremap jk <esc>


