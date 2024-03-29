" Avoid the escape key
inoremap jk <esc>:w<cr>

let mapleader = "," " map leader to comma

nmap <leader>vr :sp $MYVIMRC<cr>
nmap <leader>so :source $MYVIMRC<cr>

" More helpful beginning of line
nmap 0 ^

set nocompatible              " be iMproved, required
filetype off                  " required


" Adapting from Vundle to Plug for neovim
call plug#begin()

Plug 'VundleVim/Vundle.vim'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'airblade/vim-gitgutter'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'davidhalter/jedi-vim'
Plug 'joshdick/onedark.vim'
Plug 'mattn/emmet-vim'
Plug 'preservim/nerdtree'
Plug 'vim-python/python-syntax'
Plug 'junegunn/vim-emoji'
Plug 'vim-airline/vim-airline'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-fugitive'
" Plug 'ambv/black'
Plug 'dense-analysis/ale'
Plug 'puremourning/vimspector'
Plug 'szw/vim-maximizer'
Plug 'preservim/tagbar'
Plug 'tpope/vim-commentary'
Plug 'vim-test/vim-test'
Plug 'raimon49/requirements.txt.vim'
Plug 'lepture/vim-jinja'
Plug 'simnalamburt/vim-mundo'
Plug 'shmup/vim-sql-syntax'

call plug#end()
filetype plugin indent on   

" Venv nonsense
" let g:black_virtualenv="~/.vim_black"
" A few more things from https://dougblack.io/words/a-good-vimrc.html
set number
set background=dark
set cursorline
set showmatch
set showcmd

let g:user_emmet_install_global = 1
let g:python_highlight_all = 1
set completefunc=emoji#complete
" let g:vimspector_base_dir='/home/discord/.vim/bundle/vimspector'

" Show hidden files
let g:ctrlp_show_hidden = 1
let g:ctrlp_max_files = 0
let g:ctrlp_max_depth = 40
let NERDTreeShowHidden = 1

" Start NERDTree automatically
" autocmd vimenter * NERDTree
" autocmd StdinReadPre * let s:std_in=1
" autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" Autoformat Python code upon saving
" autocmd BufWritePre *.py execute ':Black'


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

" Toggle tagbar remap
nmap <leader>tt :TagbarToggle<CR>

" Debugger remaps
" mostly from ThePrimagean
" https://github.com/awesome-streamers/awesome-streamerrc/blob/master/ThePrimeagen/plugin/vimspector.vim
fun! GotoWindow(id)
    call win_gotoid(a:id)
    MaximizerToggle
endfun

nnoremap <leader>m :MaximizerToggle!<CR>
nnoremap <leader>dd :call vimspector#Launch()<CR>
nnoremap <leader>dc :call GotoWindow(g:vimspector_session_windows.code)<CR>
nnoremap <leader>dt :call GotoWindow(g:vimspector_session_windows.tagpage)<CR>
nnoremap <leader>dv :call GotoWindow(g:vimspector_session_windows.variables)<CR>
nnoremap <leader>dw :call GotoWindow(g:vimspector_session_windows.watches)<CR>
nnoremap <leader>ds :call GotoWindow(g:vimspector_session_windows.stack_trace)<CR>
nnoremap <leader>do :call GotoWindow(g:vimspector_session_windows.output)<CR>
nnoremap <leader>de :call vimspector#Reset()<CR>

nmap <leader>dl <Plug>VimspectorStepInto
nmap <leader>dj <Plug>VimspectorStepOver
nmap <leader>dk <Plug>VimspectorStepOut
nmap <leader>d_ <Plug>VimspectorRestart
nnoremap <leader>d<space> :call vimspector#Continue()<CR>

nmap <leader>drc <Plug>VimspectorRunToCursor
nmap <leader>dbp <Plug>VimspectorToggleBreakpoint
nmap <leader>dcbp <Plug>VimspectorToggleConditionalBreakpoint

" Vim test remaps

" DBT syntax highlighting
au BufNewFile,BufRead *.sql set ft=dbt

" Undofile
set undofile
set undodir=~/.vim/undo
