return {
  cmd = {
    'bun',
    'x',
    '--bun',
    'vscode-langservers-extracted',
    'vscode-json-language-server',
    '--stdio',
  },
  filetypes = { 'json', 'jsonc', 'json5' },
  mason = false,
  setup = {
    settings = {
      json = {
        schemas = require('schemastore').json.schemas(),
        validate = { enable = true },
      },
    },
  },
}
