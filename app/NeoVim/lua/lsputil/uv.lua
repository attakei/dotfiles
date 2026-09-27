-- Helpers for language servers launched via `uv run` in the project environment.
local M = {}

--- Return true if `uv.lock` declares the package `pkg`.
local function locked(lockfile, pkg)
  local f = io.open(lockfile, 'r')
  if not f then
    return false
  end
  local pattern = '^name = "' .. vim.pesc(pkg) .. '"$'
  for line in f:lines() do
    if line:match(pattern) then
      f:close()
      return true
    end
  end
  f:close()
  return false
end

--- Build a config that starts `uv run <pkg> <args...>` only when the project locks `pkg`.
---@param pkg string
---@param args string[]
---@return vim.lsp.Config
function M.config(pkg, args)
  return {
    cmd = function(dispatchers, config)
      return vim.lsp.rpc.start(
        vim.list_extend({ 'uv', 'run', pkg }, args),
        dispatchers,
        { cwd = config.root_dir }
      )
    end,
    root_dir = function(bufnr, on_dir)
      local root = vim.fs.root(bufnr, { 'uv.lock' })
      if root and locked(vim.fs.joinpath(root, 'uv.lock'), pkg) then
        on_dir(root)
      end
    end,
  }
end

return M
