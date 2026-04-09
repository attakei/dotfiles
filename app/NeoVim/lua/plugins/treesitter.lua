return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      -- Install parsers using main branch API (ensure_installed was removed)
      -- install() is a no-op if already up-to-date
      require('nvim-treesitter').install({ 'lua', 'vim', 'vimdoc', 'markdown', 'nu' })
    end,
  },
}
