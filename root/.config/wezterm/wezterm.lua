local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- System
config.automatically_reload_config = true
config.allow_win32_input_mode = false

--  Window
config.window_background_opacity = 0.8
config.initial_rows = 40
config.initial_cols = 160

--  Design
config.font = wezterm.font("HackGen Console NF")

--  Init
config.default_prog = { "nu" }

-- Adjust for localmachine
local _f = io.open("./wezterm-local.lua", "r")
if _f ~= nil then
    io.close(_f)
else
    local localConfig = require("./wezterm-local")
    for k, v in pairs(localConfig) do
        config[k] = v
    end
end

return config
