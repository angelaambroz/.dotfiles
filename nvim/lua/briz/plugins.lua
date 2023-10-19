-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
	use 'wbthomason/packer.nvim'
	use 'VundleVim/Vundle.vim'
	use 'Xuyuanp/nerdtree-git-plugin'
	use 'airblade/vim-gitgutter'
	use 'davidhalter/jedi-vim'
	use 'joshdick/onedark.vim'
	use 'mattn/emmet-vim'
	use 'preservim/nerdtree'
	use 'vim-python/python-syntax'
	use 'junegunn/vim-emoji'
	use 'vim-airline/vim-airline'
	use 'tpope/vim-sensible'
	use 'tpope/vim-fugitive'
	use 'dense-analysis/ale'
	use 'mfussenegger/nvim-dap'
	use 'rcarriga/nvim-dap-ui'
	use 'mfussenegger/nvim-dap-python'
	use 'szw/vim-maximizer'
	use 'preservim/tagbar'
	use 'tpope/vim-commentary'
	use 'vim-test/vim-test'
	use 'raimon49/requirements.txt.vim'
	use 'lepture/vim-jinja'
	use 'simnalamburt/vim-mundo'
	use 'shmup/vim-sql-syntax'
	use "nvim-lua/plenary.nvim"
	use { "nvim-telescope/telescope.nvim",
		tag="0.1.4",
		requires={{"nvim-lua/plenary.nvim"}}
	}
	use 'Exafunction/codeium.vim'
end)
