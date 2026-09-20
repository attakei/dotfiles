-- Speed up Lua module loading on Windows via a custom bytecode cache dir.
if vim.fn.has('win32') == 1 then
  local luac_dir = vim.fn.expand('~/.cache') .. '/nvim/luac'
  vim.fn.mkdir(luac_dir, 'p')
  vim.loader.path = luac_dir
end
