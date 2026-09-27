return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'saghen/blink.cmp',
      'b0o/schemastore.nvim',
    },
    config = function()
      vim.lsp.config('*', {
        capabilities = require('blink.cmp').get_lsp_capabilities({}, false),
      })

      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        end,
      })

      -- Managed servers are those having after/lsp/<name>.lua in this config.
      -- Each config decides whether to start by its root_dir.
      local servers = {}
      local lsp_dir = vim.fs.joinpath(vim.fn.stdpath('config'), 'after', 'lsp')
      for _, file in ipairs(vim.fn.glob(lsp_dir .. '/*.lua', false, true)) do
        servers[vim.fn.fnamemodify(file, ':t:r')] = true
      end

      -- Per-project override from .nvim.lua (exrc):
      --   vim.g.lsp_servers = { disable = { 'ty' }, enable = { 'deno' } }
      local override = vim.g.lsp_servers or {}
      for _, name in ipairs(override.enable or {}) do
        servers[name] = true
      end
      for _, name in ipairs(override.disable or {}) do
        servers[name] = nil
      end

      vim.lsp.enable(vim.tbl_keys(servers))
    end,
  },
}
