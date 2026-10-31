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

-- Keep this profile's lazy state fully isolated from the main profile:
--   * root/state: under `nvim -u` NVIM_APPNAME is unset, so the stdpath('data')
--     defaults point at the *main* data dir; lazy could then uninstall the main
--     plugins on clean. Carve out a dedicated subdir in that case. Under
--     NVIM_APPNAME=nvim/SKK (WSL/Linux) stdpath('data') is already the isolated
--     SKK-data dir, so use it as-is.
--   * lockfile: never share the main config's (git-tracked) lazy-lock.json.
--     lazy rewrites the lockfile with only the current setup's spec, so an
--     install/update here would prune the main profile's 20+ pins down to just
--     skkeleton/denops. Pin a separate lockfile in the isolated data dir. The
--     trade-off is that skkeleton/denops pins are no longer kept in lock-step
--     with the main profile, which is acceptable and far safer than clobbering.
local data = vim.fn.stdpath('data')
if vim.env.NVIM_APPNAME ~= 'nvim/SKK' then
  data = data .. '/SKK'
end

local spec = dofile(MAIN_CONFIG .. '/lua/plugins/skkeleton.lua')
local lockfile = data .. '/lazy-lock.json'

-- Copy this profile's pins from the main (git-tracked) lockfile into the
-- isolated one, so `:Lazy restore` here checks out the same commits as the
-- main profile. Only entries for plugins in this profile's spec are copied;
-- the main lockfile itself is never written.
local function sync_pins_from_main()
  local function read_json(path)
    local f = io.open(path, 'rb')
    if not f then
      return nil
    end
    local ok, value = pcall(vim.json.decode, f:read('*a'))
    f:close()
    return ok and type(value) == 'table' and value or nil
  end

  local main_lock = read_json(MAIN_CONFIG .. '/lazy-lock.json')
  if not main_lock then
    return
  end

  -- Plugin names in lazy are the last path component of the spec's source.
  local names = {}
  local function collect(s)
    if type(s) == 'string' then
      names[#names + 1] = s:match('[^/]+$')
    elseif type(s) == 'table' then
      if type(s[1]) == 'string' then
        names[#names + 1] = s.name or s[1]:match('[^/]+$')
      end
      for _, dep in ipairs(s.dependencies or {}) do
        collect(dep)
      end
    end
  end
  collect(spec)

  local lock = read_json(lockfile) or {}
  local changed = false
  for _, name in ipairs(names) do
    local pin = main_lock[name]
    if pin and not vim.deep_equal(lock[name], pin) then
      lock[name] = pin
      changed = true
    end
  end
  if not changed then
    return
  end

  -- Same layout lazy.nvim writes: sorted, one entry per line.
  local keys = vim.tbl_keys(lock)
  table.sort(keys)
  local lines = {}
  for _, k in ipairs(keys) do
    local entry = lock[k]
    lines[#lines + 1] = ('  %s: { "branch": %s, "commit": %s }'):format(
      vim.json.encode(k),
      vim.json.encode(entry.branch),
      vim.json.encode(entry.commit)
    )
  end
  vim.fn.mkdir(data, 'p')
  local f = assert(io.open(lockfile, 'wb'))
  f:write('{\n' .. table.concat(lines, ',\n') .. '\n}\n')
  f:close()
end
sync_pins_from_main()

require('lazy').setup({
  spec = { spec },
  root = data .. '/lazy',
  state = data .. '/state.json',
  lockfile = lockfile,
})
