-- Core settings and remaps
require("jmiv.set")
require("jmiv.remap")

-- Bootstrap lazy.nvim
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

-- Every plugin is declared under lua/plugins/, one file per plugin, with its
-- configuration inlined in the spec.
require('lazy').setup("plugins")
