# Package

version       = "0.0.0"
author        = "Kazuya Takei"
description   = "Tool for my dotfiles repo"
license       = "Apache-2.0"
srcDir        = "src"
binDir        = ".bin"
namedBin      = {"zed_settings": "zed-settings"}.toTable()

# Dependencies

requires "nim >= 2.2.6"
