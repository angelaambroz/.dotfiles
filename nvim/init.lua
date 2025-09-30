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
   "neovim/nvim-lspconfig",
   "mfussenegger/nvim-dap",
   "mfussenegger/nvim-dap-python",
   { "rcarriga/nvim-dap-ui",
     dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"},
     lazy = false,
   },
   { "folke/neodev.nvim", opts = {} },

   -- File Navigation and Search
   { "nvim-telescope/telescope.nvim",
     version = "0.1.4",
     dependencies = {"nvim-lua/plenary.nvim"}
   },
   "nvim-lua/plenary.nvim",
   "preservim/nerdtree",
   "Xuyuanp/nerdtree-git-plugin",

   -- Git Integration
   "airblade/vim-gitgutter",
   "tpope/vim-fugitive",

   -- Appearance and UI
   "joshdick/onedark.vim",
   "vim-airline/vim-airline",
   "preservim/tagbar",

   -- Code Editing and Formatting
   { 'stevearc/conform.nvim', opts = {} },
   "mattn/emmet-vim",
   "tpope/vim-commentary",
   "Exafunction/codeium.vim",
   "szw/vim-maximizer",
   "dense-analysis/ale",

   -- Language Support
   "vim-python/python-syntax",
   "raimon49/requirements.txt.vim",
   "lepture/vim-jinja",
   "shmup/vim-sql-syntax",

   -- Misc Utilities
   "tpope/vim-sensible",
   "vim-test/vim-test",
   "simnalamburt/vim-mundo",
   "junegunn/vim-emoji",
 })

 -- Core Settings
 vim.g.mapleader = ","
 vim.opt.nu = true
 vim.wo.foldmethod = 'indent'
 vim.cmd("set foldlevel=99")

 -- Python Settings
 vim.g.python3_host_prog = "/usr/bin/python3"
 vim.g.python_highlight_all = 1

 -- Plugin Configurations
 require('dap-python').setup('~/.pyenv/shims/python')
 require("conform").setup({
   formatters_by_ft = {
     lua = { "stylua" },
     python = { "isort", "black" },
     javascript = { { "prettierd", "prettier" } },
   },
 })
 require("neodev").setup({
   library = { plugins = { "nvim-dap-ui" }, types = true },
 })
 local dapui = require("dapui")
 dapui.setup()

 -- Formatting
 require("conform").setup({
   formatters_by_ft = {
     lua = { "stylua" },
     python = { "isort", "black" },
     javascript = { { "prettierd", "prettier" } },
   },
 })

 -- Keybindings
 -- General
 vim.keymap.set("i", "jk", "<esc>:w<cr>")

 -- Telescope
 local telescope = require('telescope.builtin')
 vim.keymap.set('n', '<c-p>', telescope.find_files, {})
 vim.keymap.set('n', '<c-t>', telescope.live_grep, {})

 -- Debugger
 vim.keymap.set('n', '<F2>', require('dapui').toggle, {})
 vim.keymap.set('n', '<F3>', require('dap').toggle_breakpoint, {})
 vim.keymap.set('n', '<F4>', require('dap').continue, {})
 vim.keymap.set('n', '<F5>', require('dap').step_over, {})
 vim.keymap.set('n', '<F6>', require('dap').step_into, {})
 vim.keymap.set('n', '<F7>', require('dap').step_out, {})

 -- Misc
 vim.keymap.set('n', '<leader>tt', ':TagbarToggle<CR>', { silent = true })
 vim.keymap.set('n', '<leader>r', ':w<CR>:!uv run %<CR>', { desc = 'Run Python file with uv' })

 -- Autocommands
 vim.api.nvim_create_autocmd("BufWritePre", {
   pattern = "*",
   callback = function(args)
     require("conform").format({ bufnr = args.buf })
   end,
 })

 -- Theme
 vim.cmd("colorscheme onedark")
