return {
  'folke/todo-comments.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  event = { 'BufReadPost', 'BufNewFile' },
  opts = {},
  keys = {
    { '<leader>ft', '<cmd>TodoTelescope<cr>', desc = 'Find Todos' },
  },
}
