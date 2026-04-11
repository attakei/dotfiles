-- Bypass aqua-proxy by resolving real tool paths and prepending them to PATH.
-- Only tools listed here are resolved.
local tools = {
  'tree-sitter',
  'nu',
  'uv',
}

local sep = vim.fn.has('win32') == 1 and '\\' or '/'
local path_sep = vim.fn.has('win32') == 1 and ';' or ':'
local exe_ext = vim.fn.has('win32') == 1 and '.exe' or ''

-- Directory for hard-linked binaries when the real filename differs from the tool name
local link_dir = vim.fn.stdpath('data') .. sep .. 'aqua-bin'
vim.fn.mkdir(link_dir, 'p')

local dirs = {}
local seen = {}

for _, tool in ipairs(tools) do
  local wh = io.popen('aqua which ' .. tool)
  if wh then
    local real_path = wh:read('*l')
    wh:close()
    if real_path then
      real_path = real_path:gsub('%s+$', '')
      local dir = real_path:match('(.+)[/\\][^/\\]+$')
      local real_name = real_path:match('[/\\]([^/\\]+)$')
      local expected_name = tool .. exe_ext

      if real_name == expected_name then
        -- Filename matches: just prepend the directory
        if dir and not seen[dir] then
          seen[dir] = true
          table.insert(dirs, dir)
        end
      else
        -- Filename differs: create a hard link in link_dir
        local link_path = link_dir .. sep .. expected_name
        os.remove(link_path) -- clean up stale link
        if vim.fn.has('win32') == 1 then
          os.execute('cmd /c mklink /H "' .. link_path .. '" "' .. real_path .. '"')
        else
          os.execute('ln -f "' .. real_path .. '" "' .. link_path .. '"')
        end
        if not seen[link_dir] then
          seen[link_dir] = true
          table.insert(dirs, link_dir)
        end
      end
    end
  end
end

-- Prepend resolved directories to PATH
if #dirs > 0 then
  vim.env.PATH = table.concat(dirs, path_sep) .. path_sep .. vim.env.PATH
end
