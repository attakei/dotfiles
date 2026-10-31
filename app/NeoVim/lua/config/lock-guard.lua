-- Guard lazy-lock.json against drift between environments.
--
-- lazy.nvim rewrites the whole lockfile with the *installed* commits of every
-- plugin after any install/update/restore (including the auto-install of
-- missing plugins on startup). On an environment whose plugins are older than
-- the lockfile, that silently reverts the lockfile to stale commits.
--
-- Usage (in init.lua):
--   local guard = require('config.lock-guard').before_setup()
--   require('lazy').setup(...)
--   guard.after_setup()
local M = {}

local lockfile = vim.fn.stdpath('config') .. '/lazy-lock.json'
local root = vim.fn.stdpath('data') .. '/lazy'

local function read(path)
  local f = io.open(path, 'rb')
  if not f then
    return nil
  end
  local data = f:read('*a')
  f:close()
  return data
end

local function write(path, data)
  local f = assert(io.open(path, 'wb'))
  f:write(data)
  f:close()
end

--- Find installed plugins whose HEAD differs from the lockfile.
---@param content string lockfile content
---@return string[]
local function find_drift(content)
  local ok, lock = pcall(vim.json.decode, content)
  if not ok or type(lock) ~= 'table' then
    return {}
  end
  local Git = require('lazy.manage.git')
  local drift = {}
  for name, entry in pairs(lock) do
    local dir = root .. '/' .. name
    if vim.uv.fs_stat(dir .. '/.git') then
      local info = Git.info(dir)
      if not (info and info.commit and Git.eq(info, entry)) then
        table.insert(drift, name)
      end
    end
  end
  table.sort(drift)
  return drift
end

function M.before_setup()
  local original = read(lockfile)
  local drift = original and find_drift(original) or {}

  return {
    after_setup = function()
      if #drift == 0 then
        return
      end
      -- Startup install may have rewritten the lockfile with stale commits.
      if read(lockfile) ~= original then
        write(lockfile, original)
      end
      vim.schedule(function()
        vim.notify(
          ('Installed plugins differ from lazy-lock.json: %s\nRun :Lazy restore to sync.'):format(
            table.concat(drift, ', ')
          ),
          vim.log.levels.WARN,
          { title = 'lazy-lock guard' }
        )
      end)
    end,
  }
end

return M
