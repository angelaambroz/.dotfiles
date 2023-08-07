vim.g.mapleader = ","
vim.g.python3_host_prog = "/usr/bin/python3"
vim.g.python_highlight_all = 1
vim.g.ctrlp_show_hidden = 1
vim.g.ctrlp_max_files = 0
vim.g.ctrlp_max_depth = 40

vim.opt.nu = true

vim.keymap.set("i", "jk", "<esc>:w<cr>")
vim.cmd("colorscheme onedark")

local tscope = require('telescope.builtin')
vim.keymap.set('n', '<c-p>', tscope.find_files, {})
vim.keymap.set('n', '<c-t>', tscope.live_grep, {})

vim.wo.foldmethod = 'indent'

