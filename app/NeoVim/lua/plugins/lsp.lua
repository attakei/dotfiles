return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'saghen/blink.cmp',
    },
    config = function()
      vim.lsp.config('*', {
        capabilities = require('blink.cmp').get_lsp_capabilities({}, false),
      })

      require('mason').setup()
      require('mason-lspconfig').setup({
        ensure_installed = { 'lua_ls' },
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

      -- Load per-server configs from lua/lsp/*.lua
      local lsp_dir = vim.fn.stdpath('config') .. '/lua/mylsp'
      for _, file in ipairs(vim.fn.glob(lsp_dir .. '/*.lua', false, true)) do
        local server = vim.fn.fnamemodify(file, ':t:r')
        local ok, config = pcall(require, 'mylsp.' .. server)
        if ok then
          vim.lsp.config(server, config)
        end
      end

      local servers = { 'jsonls' }
      for _, server in ipairs(servers) do
        vim.lsp.enable(server)
      end
    end,
  },
}
