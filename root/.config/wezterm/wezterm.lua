local package = require("package")
local wezterm = require("wezterm")
local config = wezterm.config_builder()

local function exec_name(name)
    if os.getenv("USERPROFILE") then  -- For Windows
        return name .. '.exe'
    end
    return name
end

local function sep()
    if package.config:sub(1,1) == '\\' then
        return '\\'
    else 
        return '/'
    end
end

local function localconf_exists()
    local conf_dir
    if os.getenv("WEZTERM_CONFIG_DIR") then
        conf_dir = os.getenv("WEZTERM_CONFIG_DIR")
    elseif os.getenv("HOME") then  -- For Linux
        conf_dir = os.getenv("HOME") .. sep() .. ".config" .. sep() .. "wezterm"
    elseif os.getenv("USERPROFILE") then  -- For Windows
        conf_dir = os.getenv("USERPROFILE") .. sep() .. ".config" .. sep() .. "wezterm"
    end
    local path = conf_dir .. sep() .. "wezterm-local.lua"
    local f = io.open(path, "r")
    return f ~= nil and io.close(f)
end

-- System
config.automatically_reload_config = true
config.allow_win32_input_mode = false

--  Window
-- config.window_background_opacity = 0.8
config.initial_rows = 40
config.initial_cols = 160

--  Design
config.font = wezterm.font("HackGen Console NF")

--  Start up command
config.default_prog = { exec_name('nu') }

-- Adjust for local-machine
if localconf_exists() then
    local localConfig = require("./wezterm-local")
    for k, v in pairs(localConfig) do
        config[k] = v
    end
end

return config
