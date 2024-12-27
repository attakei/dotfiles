local wezterm = require("wezterm")
local config = {}

--  Window
config.window_background_opacity = 0.8
config.initial_rows = 40
config.initial_cols = 160

--  Design
config.font = wezterm.font("HackGen Console NF")

--  Init
config.default_prog = { "nu" }

return config