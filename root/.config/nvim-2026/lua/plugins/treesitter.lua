return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      local configs = pcall(require, 'nvim-treesitter.configs')
      if configs then
        require('nvim-treesitter.configs').setup({
          ensure_installed = { 'lua', 'vim', 'vimdoc', 'markdown' },
          highlight = { enable = true },
        })
      end
    end,
  },
}
