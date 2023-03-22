vim.g.mapleader = ","
vim.g.python_highlight_all = 1
vim.g.ctrlp_show_hidden = 1
vim.g.ctrlp_max_files = 0
vim.g.ctrlp_max_depth = 40

vim.opt.nu = true

vim.keymap.set("i", "jk", "<esc>:w<cr>")
vim.cmd("colorscheme onedark")