vim.g.mapleader = ","
vim.g.python3_host_prog = "/usr/bin/python3"
vim.g.python_highlight_all = 1
vim.g.ctrlp_show_hidden = 1
vim.g.ctrlp_max_files = 0
vim.g.ctrlp_max_depth = 40

vim.opt.nu = true

vim.keymap.set("i", "jk", "<esc>:w<cr>")
vim.cmd("colorscheme onedark")

-- Telecope
-- AKA, searching files
-- https://github.com/nvim-telescope/telescope.nvim
local tscope = require('telescope.builtin')
vim.keymap.set('n', '<c-p>', tscope.find_files, {})
vim.keymap.set('n', '<c-t>', tscope.live_grep, {})

vim.wo.foldmethod = 'indent'
vim.cmd("set foldlevel=99")

-- Format on save
-- I'm pretty sure this is set to `black`
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    require("conform").format({ bufnr = args.buf })
  end,
})

-- Debugger keybindings
-- https://github.com/mfussenegger/nvim-dap
vim.keymap.set('n', '<F2>', require('dapui').toggle, {})
vim.keymap.set('n', '<F3>', require('dap').toggle_breakpoint, {})
vim.keymap.set('n', '<F4>', require('dap').continue, {})
vim.keymap.set('n', '<F5>', require('dap').step_over, {})
vim.keymap.set('n', '<F6>', require('dap').step_into, {})
vim.keymap.set('n', '<F7>', require('dap').step_out, {})
