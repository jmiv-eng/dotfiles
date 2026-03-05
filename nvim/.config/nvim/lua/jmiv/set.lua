vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.guicursor = ""
vim.opt.hlsearch = false
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true
vim.opt.scrolloff = 8
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")
vim.opt.updatetime = 50
vim.opt.timeoutlen = 300
vim.opt.termguicolors = true
vim.opt.colorcolumn = "100"
vim.opt.completeopt = 'menuone,noselect'
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
