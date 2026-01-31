-- Fallback color scheme
vim.cmd('colorscheme default')

-- Bootstrap lazy.nvim package manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

--- Plugin Specifications
require("lazy").setup({
  -- LSP and Debugging
  "neovim/nvim-lspconfig",              -- LSP configuration (autocomplete, go-to-def, etc.) - NOT ACTUALLY CONFIGURED YET
  "mfussenegger/nvim-dap",              -- Debug Adapter Protocol client (debugger core)
  "mfussenegger/nvim-dap-python",       -- Python debugger integration for DAP
  { "rcarriga/nvim-dap-ui",             -- Visual debugger UI (breakpoints panel, variables, stack trace)
    dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"},
    lazy = false,
  },
  { "folke/neodev.nvim", opts = {} },   -- Better LSP support for Neovim's Lua API (helps with nvim config dev)

  -- Syntax Highlighting
  { 
  	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate"
  },

  -- File Navigation and Search
  { "nvim-telescope/telescope.nvim",    -- Fuzzy finder (Ctrl-P for files, Ctrl-T for grep)
    version = "0.1.4",
    dependencies = {"nvim-lua/plenary.nvim"}
  },
  "nvim-lua/plenary.nvim",              -- Lua utility library (dependency for many plugins)
  "preservim/nerdtree",                 -- File tree sidebar (classic file browser)
  "Xuyuanp/nerdtree-git-plugin",        -- Shows git status in NERDTree

  -- Git Integration
  "airblade/vim-gitgutter",             -- Shows git diff in the gutter (added/removed/modified lines)
  "tpope/vim-fugitive",                 -- Git commands inside vim (:Git blame, :Git diff, etc.)

  -- Appearance and UI
  "joshdick/onedark.vim",               -- OneDark color scheme (Atom editor colors)
  "vim-airline/vim-airline",            -- Fancy statusline at bottom
  "preservim/tagbar",                   -- Sidebar showing code structure (functions, classes) - <leader>tt

  -- Code Editing and Formatting
  -- { 'stevearc/conform.nvim', opts = {} }, -- Auto-formatter (runs black/isort on save)
  "mattn/emmet-vim",                    -- HTML/CSS abbreviation expansion (type div.class then expand)
  "tpope/vim-commentary",               -- Toggle comments with gc motion
  "Exafunction/codeium.vim",            -- AI code completion (Copilot alternative)
  "szw/vim-maximizer",                  -- Maximize/restore current split
  "dense-analysis/ale",                 -- Async linting (shows errors as you type)

  -- Language Support
  "vim-python/python-syntax",           -- Better Python syntax highlighting
  "raimon49/requirements.txt.vim",      -- Syntax for requirements.txt files
  "lepture/vim-jinja",                  -- Jinja2 template syntax
  "shmup/vim-sql-syntax",               -- SQL syntax highlighting

  -- Misc Utilities
  "tpope/vim-sensible",                 -- Sensible defaults for vim settings
  "simnalamburt/vim-mundo",             -- Visual undo tree (see undo history as tree)
  "junegunn/vim-emoji",                 -- Emoji completion :emoji_name:
})

-- Core Settings
vim.g.mapleader = ","                   -- Leader key is comma
vim.opt.nu = true                       -- Show line numbers
vim.wo.foldmethod = 'indent'            -- Fold based on indentation
vim.cmd("set foldlevel=99")             -- Start with all folds open

-- Map 0 to jump to first non-blank character (instead of start of line)
vim.keymap.set({'n', 'v'}, '0', '^', { noremap = true })

-- Python Settings
vim.g.python3_host_prog = "/usr/bin/python3"  -- Python provider path
vim.g.python_highlight_all = 1                -- Enable all Python highlighting

-- Plugin Configurations
require('dap-python').setup(vim.fn.exepath('python3'))  -- Debugger uses python3

-- Treesitter configuration
require'nvim-treesitter'.setup {
  -- Directory to install parsers and queries to (prepended to `runtimepath` to have priority)
  install_dir = vim.fn.stdpath('data') .. '/site'
}

-- require("conform").setup({              -- Auto-formatter config
--   formatters_by_ft = {
--     lua = { "stylua" },
--     python = { "isort", "black" },      -- isort for imports, black for code
--     javascript = { { "prettierd", "prettier" } },
--   },
-- })

require("neodev").setup({               -- Lua LSP setup for neovim development
  library = { plugins = { "nvim-dap-ui" }, types = true },
})

local dapui = require("dapui")
dapui.setup()                           -- Initialize debugger UI

-- Keybindings
-- General
vim.keymap.set("i", "jk", "<esc>:w<cr>")  -- jk in insert mode = escape and save

-- Telescope
local telescope = require('telescope.builtin')
vim.keymap.set('n', '<c-p>', telescope.find_files, {})  -- Ctrl-P: fuzzy find files
vim.keymap.set('n', '<c-t>', telescope.live_grep, {})   -- Ctrl-T: grep search

-- Debugger (F-keys)
vim.keymap.set('n', '<F2>', require('dapui').toggle, {})         -- F2: toggle debug UI
vim.keymap.set('n', '<F3>', require('dap').toggle_breakpoint, {}) -- F3: set breakpoint
vim.keymap.set('n', '<F4>', require('dap').continue, {})          -- F4: start/continue
vim.keymap.set('n', '<F5>', require('dap').step_over, {})         -- F5: step over
vim.keymap.set('n', '<F6>', require('dap').step_into, {})         -- F6: step into
vim.keymap.set('n', '<F7>', require('dap').step_out, {})          -- F7: step out

-- Misc
vim.keymap.set('n', '<leader>tt', ':TagbarToggle<CR>', { silent = true })  -- ,tt: toggle tagbar
vim.keymap.set('n', '<leader>r', ':w<CR>:!uv run %<CR>', { desc = 'Run Python file with uv' })  -- ,r: run with uv

-- Autocommands
-- vim.api.nvim_create_autocmd("BufWritePre", {  -- Format on save
--   pattern = "*",
--   callback = function(args)
--     require("conform").format({ bufnr = args.buf })
--   end,
-- })

-- Theme
vim.cmd("colorscheme onedark")
