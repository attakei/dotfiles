-- Minimal NeoVim profile that enables only skkeleton (SKK input).
-- Used in place of `nvim --clean` (e.g. as $EDITOR for `git commit`) when
-- SKK input is needed. Launch with: NVIM_APPNAME=nvim/SKK nvim
--
-- This is nested under the main config (app/NeoVim) so it is deployed by
-- the same symlink as the main config, and reuses the main config's shared
-- bootstrap modules and the skkeleton plugin spec directly via relative
-- `dofile`, instead of duplicating them. As long as this file stays one
-- directory below the main config's root, nothing here needs to change
-- when those shared files change.
local MAIN_CONFIG = vim.fn.stdpath('config') .. '/..'

dofile(MAIN_CONFIG .. '/lua/config/win32-loader.lua')
dofile(MAIN_CONFIG .. '/lua/config/lazy-bootstrap.lua')

require('lazy').setup({
  spec = { dofile(MAIN_CONFIG .. '/lua/plugins/skkeleton.lua') },
  -- Share the main config's lockfile instead of generating a separate one:
  -- skkeleton/denops.vim are pinned there too, so there is nothing to
  -- reconcile between the two.
  lockfile = MAIN_CONFIG .. '/lazy-lock.json',
})
