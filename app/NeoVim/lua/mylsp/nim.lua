return {
  mason = false,
  cmd = function(dispatchers, config)
    local bin_path = vim.fn.trim(vim.fn.system('aqua which nimlangserver'))
    return vim.lsp.rpc.start({ bin_path }, dispatchers, { cwd = config.root_dir })
  end,
}
