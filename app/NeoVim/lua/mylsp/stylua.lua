return {
  mason = false,
  filetypes = { 'lua' },
  cmd = function(dispatchers, config)
    local cmd_bin = vim.fn.trim(vim.fn.system('aqua which stylua'))
    return vim.lsp.rpc.start({ cmd_bin, '--lsp' }, dispatchers, { cwd = config.root_dir })
  end,
}
