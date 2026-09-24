-- Minimal NeoVim profile that enables only skkeleton (SKK input).
-- Used in place of `nvim --clean` (e.g. as $EDITOR for `git commit`) when
-- SKK input is needed. Two launch paths reach this file:
--   * WSL/Linux: `NVIM_APPNAME=nvim/SKK nvim` (config/data are isolated by
--     NVIM_APPNAME).
--   * Windows native: `nvim -u <this file>` -- POSIX `env` is not on the
--     native PATH, so NVIM_APPNAME cannot be set that way; `-u` avoids it.
--
-- This is nested under the main config (app/NeoVim) so it is deployed by
-- the same symlink as the main config, and reuses the main config's shared
-- bootstrap modules and the skkeleton plugin spec directly via relative
-- `dofile`, instead of duplicating them. As long as this file stays one
-- directory below the main config's root, nothing here needs to change
-- when those shared files change.
--
-- Locate ourselves instead of relying on stdpath('config'): under `nvim -u`
-- NVIM_APPNAME is unset, so stdpath('config') points at the *main* profile,
-- not this SKK dir. debug.getinfo gives the path this file was loaded from,
-- which works in both launch paths above.
local SELF = debug.getinfo(1, 'S').source:sub(2)
local SKK_DIR = vim.fn.fnamemodify(SELF, ':p:h') -- .../nvim/SKK
local MAIN_CONFIG = vim.fn.fnamemodify(SKK_DIR, ':h') -- .../nvim

dofile(MAIN_CONFIG .. '/lua/config/win32-loader.lua')
dofile(MAIN_CONFIG .. '/lua/config/lazy-bootstrap.lua')
-- skkeleton は denops (Deno) 上で動く。aqua のプロキシ shim 経由だと denops が
-- Deno サーバーを起動できず "Failed to connect channel" になるため、実体の
-- deno パスを解決して PATH へ前置する。denops (lazy=false) が起動する
-- lazy.setup より前に実行する必要がある。
dofile(MAIN_CONFIG .. '/lua/config/aqua-path.lua')

local opts = {
  spec = { dofile(MAIN_CONFIG .. '/lua/plugins/skkeleton.lua') },
  -- Share the main config's lockfile instead of generating a separate one:
  -- skkeleton/denops.vim are pinned there too, so there is nothing to
  -- reconcile between the two.
  lockfile = MAIN_CONFIG .. '/lazy-lock.json',
}

-- Under `nvim -u` (Windows $EDITOR) NVIM_APPNAME is unset, so lazy would
-- default its plugin root to the *main* profile's data dir and could
-- uninstall the main plugins on clean. Pin an isolated root/state in that
-- case. Under NVIM_APPNAME=nvim/SKK (WSL/Linux $EDITOR) the stdpath('data')
-- defaults are already isolated, so leave them untouched.
if vim.env.NVIM_APPNAME ~= 'nvim/SKK' then
  local data = vim.fn.stdpath('data') .. '/SKK'
  opts.root = data .. '/lazy'
  opts.state = data .. '/state.json'
end

require('lazy').setup(opts)
