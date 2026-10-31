require('config.win32-loader')
require('config.lazy-bootstrap')

-- Load options
require('config.options')
require('config.aqua-path')
require('config.filetypes')

-- Enable plugins
local lock_guard = require('config.lock-guard').before_setup()
require('lazy').setup('plugins')
lock_guard.after_setup()
