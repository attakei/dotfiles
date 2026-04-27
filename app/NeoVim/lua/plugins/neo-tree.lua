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
      mappings = {
        ["l"] = function(state)
          local node = state.tree:get_node()
          if node.type == "directory" then
            if not node:is_expanded() then
              require("neo-tree.sources.filesystem").toggle_directory(state, node)
            end
          else
            require("neo-tree.sources.filesystem.commands").open(state)
          end
        end,
        ["h"] = function(state)
          local node = state.tree:get_node()
          if node.type == "directory" and node:is_expanded() then
            require("neo-tree.sources.filesystem").toggle_directory(state, node)
          else
            require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
          end
        end,
      },
    },
  },
}
