-- Fallback color scheme
vim.cmd('colorscheme default')

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

--- Plugins
require("lazy").setup({
	"neovim/nvim-lspconfig",
	"VundleVim/Vundle.vim",
	"Xuyuanp/nerdtree-git-plugin",
	"airblade/vim-gitgutter",
	-- "davidhalter/jedi-vim",
	"joshdick/onedark.vim",
	"mattn/emmet-vim",
	"preservim/nerdtree",
	"vim-python/python-syntax",
	"junegunn/vim-emoji",
	"vim-airline/vim-airline",
	"tpope/vim-sensible",
	"tpope/vim-fugitive",
	"dense-analysis/ale",
	"szw/vim-maximizer",
	"preservim/tagbar",
	"tpope/vim-commentary",
	"vim-test/vim-test",
	"raimon49/requirements.txt.vim",
	"lepture/vim-jinja",
	"simnalamburt/vim-mundo",
	"shmup/vim-sql-syntax",
	"nvim-lua/plenary.nvim",
	{ "nvim-telescope/telescope.nvim",
		version="0.1.4",
		dependencies={"nvim-lua/plenary.nvim"}
	},
	"Exafunction/codeium.vim",
	"mfussenegger/nvim-dap",
	"mfussenegger/nvim-dap-python",
	{
		  'stevearc/conform.nvim',
		  opts = {},
	},
	{ "rcarriga/nvim-dap-ui", dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"} },
	{ "folke/neodev.nvim", opts = {} }
})

require('dap-python').setup('~/.pyenv/shims/python')
require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    -- Conform will run multiple formatters sequentially
    python = { "isort", "black" },
    -- Use a sub-list to run only the first available formatter
    javascript = { { "prettierd", "prettier" } },
  },
})
require("neodev").setup({
  library = { plugins = { "nvim-dap-ui" }, types = true },
})
require'lspconfig'.pyright.setup{}

-- require("briz.plugins")
require("briz.remap")
