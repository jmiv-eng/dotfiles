-- custom remaps
require("jmiv.set")
require("jmiv.remap")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- Prepend the lazy.nvim treesitter parser directory so that locally managed
-- parsers are found before any system-wide parsers under /usr/lib or
-- /usr/share, which can be out of sync and cause runtime errors.
vim.opt.runtimepath:prepend(vim.fn.stdpath('data') .. '/lazy/nvim-treesitter')

require('lazy').setup("plugins")
require('config.telescope')
require('config.lspconfig')
require('config.vimtex')
