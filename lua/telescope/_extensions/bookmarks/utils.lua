local utils = {}

local telescope_utils = require "telescope.utils"

local path_sep = require("plenary.path").path.sep

---Emit a warning message.
---@param msg string
function utils.warn(msg)
  vim.api.nvim_echo(
    { { "[telescope-bookmarks] " .. msg, "WarningMsg" } },
    true,
    {}
  )
end

---Wrapper around telescope utility function `get_os_command_output` to raise
---an error if there are any, otherwise return the output as it is.
---@param command table
---@return table
function utils.get_os_command_output(command)
  local output, code, err = telescope_utils.get_os_command_output(command)
  if code > 0 then
    error(table.concat(err, "\n"))
  end
  return output
end

---Return a path string made up of the given mix of strings or tables.
---@param ... string|[]string
---@return string
function utils.join_path(...)
  local components = {}
  for i = 1, select("#", ...) do
    local component = select(i, ...)
    if type(component) == "table" then
      table.insert(components, table.concat(component, path_sep))
    elseif type(component) == "string" then
      table.insert(components, component)
    end
  end
  return table.concat(components, path_sep)
end

return utils
