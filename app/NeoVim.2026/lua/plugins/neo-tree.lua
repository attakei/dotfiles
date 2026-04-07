vim.keymap.set('n', '<leader>e', '<Cmd>Neotree<CR>')

return {
  'nvim-neo-tree/neo-tree.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    'nvim-tree/nvim-web-devicons', -- optional, but recommended
  },
  opts = {
    sources = { 'filesystem', 'buffers', 'git_status' },
    source_selector = {
      winbar = true,
      statusline = false,
    },
    filesystem = {
      filtered_items = {
        hide_dotfiles = false,
        hide_by_name = {
          '.git',
        },
      },
    },
    window = {
      width = 30,
    },
  },
}
