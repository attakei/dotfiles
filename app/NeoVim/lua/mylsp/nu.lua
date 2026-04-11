return {
  mason = false,
  cmd = function(dispatchers, config)
    local bin_path = vim.fn.trim(vim.fn.system('aqua which nu'))
    return vim.lsp.rpc.start({ bin_path, '--lsp' }, dispatchers, { cwd = config.root_dir })
  end,
}
