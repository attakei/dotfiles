if vim.fn.has('win32') == 1 then
  local luac_dir = vim.fn.expand('~/.cache') .. '/nvim/luac'
  vim.fn.mkdir(luac_dir, 'p')
  vim.loader.path = luac_dir
end

-- Fetch lazy.nvim if it is not exists.
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load options
require('config.options')
require('config.aqua-path')

-- Enable plugins
require('lazy').setup('plugins')
