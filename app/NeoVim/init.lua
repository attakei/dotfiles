require('config.win32-loader')
require('config.lazy-bootstrap')

-- Load options
require('config.options')
require('config.aqua-path')
require('config.filetypes')

-- Enable plugins
require('lazy').setup('plugins')
