vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true
vim.opt.clipboard = 'unnamedplus'
vim.opt.exrc = true

-- Keybindings
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>')

if vim.fn.has('win32') == 1 then
  -- For using Nushell internal shell for Windows
  vim.opt.shell = 'nu'
  vim.opt.shellcmdflag = '-c'
  vim.opt.shellquote = ''
  vim.opt.shellxquote = ''
end
