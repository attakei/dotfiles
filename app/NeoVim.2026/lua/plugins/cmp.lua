return {
  'saghen/blink.cmp',
  dependencies = { 'L3MON4D3/LuaSnip' },
  version = '*',
  opts = {
    snippets = { preset = 'luasnip' },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },
  },
}
