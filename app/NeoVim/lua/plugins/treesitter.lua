return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      -- Install parsers using main branch API (ensure_installed was removed)
      -- install() is a no-op if already up-to-date
      -- lua/vim/vimdoc/markdown/markdown_inline are bundled with nvim itself
      -- On Windows, tree-sitter build fails (LoadLibraryExW error 126)
      if vim.fn.has('win32') == 0 then
        require('nvim-treesitter').install({ 'nu' })
      end
    end,
  },
}
