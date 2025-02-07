local wezterm = require("wezterm")
local config = wezterm.config_builder()

local function localconf_exists()
    local conf_dir = os.getenv("WEZTERM_CONFIG_DIR")
    if conf_dir ~= nil then
    else
        conf_dir = os.getenv("HOME") .. "/.config/wezterm"
    end
    local path = conf_dir .. "/wezterm-local.lua"
    local f = io.open(path, "r")
    return f ~= nil and io.close(f)
end

-- System
config.automatically_reload_config = true
config.allow_win32_input_mode = false

--  Window
config.window_background_opacity = 0.8
config.initial_rows = 40
config.initial_cols = 160

--  Design
config.font = wezterm.font("HackGen Console NF")

--  Start up command
config.default_prog = { "nu" }

-- Adjust for local-machine
if localconf_exists() then
    local localConfig = require("./wezterm-local")
    for k, v in pairs(localConfig) do
        config[k] = v
    end
end

return config
