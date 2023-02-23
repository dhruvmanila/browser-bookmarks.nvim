local helpers = {}

local state = require "browser_bookmarks.state"

-- Read the content from the given filename.
---@param filename string
---@return string
function helpers.readfile(filename)
  local file = io.open(filename, "r")
  if not file then
    error("Unable to open the file: " .. filename)
  end
  local content = file:read "*a"
  if not content then
    error("Unable to read the file: " .. filename)
  end
  file:close()
  return content
end

-- Set the state for a test case. This includes setting the OS name and/or
-- home directory path
---@param new_state {os_name: string, os_homedir: string, cwd: string}
function helpers.set_state(new_state)
  for k, v in pairs(new_state) do
    state[k] = v
  end
end

return helpers
