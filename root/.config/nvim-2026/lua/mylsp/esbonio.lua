return {
  cmd = function(dispatchers, config)
    local uv_bin = vim.fn.trim(vim.fn.system('aqua which uv'))
    return vim.lsp.rpc.start(
      { uv_bin, 'run', 'esbonio' },
      -- { 'uv', 'run', 'esbonio' },
      dispatchers,
      { cwd = config.root_dir }
    )
  end,
}
