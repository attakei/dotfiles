local config = require('lsputil.uv').config('ruff', { 'server' })

local TIMEOUT_MS = 3000

--- Apply the `source.fixAll.ruff` code action (same as `ruff check --fix`) synchronously.
---@param client vim.lsp.Client
---@param bufnr integer
local function fix_all(client, bufnr)
  local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
  params.range = {
    start = { line = 0, character = 0 },
    ['end'] = { line = vim.api.nvim_buf_line_count(bufnr), character = 0 },
  }
  params.context = { only = { 'source.fixAll.ruff' }, diagnostics = {} }
  local res = client:request_sync('textDocument/codeAction', params, TIMEOUT_MS, bufnr)
  for _, action in ipairs(res and res.result or {}) do
    if not action.edit and client:supports_method('codeAction/resolve') then
      local resolved = client:request_sync('codeAction/resolve', action, TIMEOUT_MS, bufnr)
      action = resolved and resolved.result or action
    end
    if action.edit then
      vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
    end
  end
end

-- On save, run `ruff check --fix` then `ruff format` (via LSP)
-- only for buffers that the ruff server is attached to.
config.on_attach = function(client, bufnr)
  vim.api.nvim_create_autocmd('BufWritePre', {
    group = vim.api.nvim_create_augroup('ruff-format-on-save.' .. bufnr, { clear = true }),
    buffer = bufnr,
    callback = function()
      if #vim.lsp.get_clients({ bufnr = bufnr, id = client.id }) == 0 then
        return
      end
      fix_all(client, bufnr)
      vim.lsp.buf.format({ bufnr = bufnr, id = client.id, timeout_ms = TIMEOUT_MS })
    end,
  })
end

return config
